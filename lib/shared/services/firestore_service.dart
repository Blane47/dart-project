import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';

/// Data-layer access to the account stored in Cloud Firestore.
///
/// Schema (see docs/FIREBASE_SETUP.md):
///   users/{uid}                       -> UserProfile (incl. balance)
///   users/{uid}/transactions/{id}     -> BankTransaction
///
/// Balance is only ever changed through [recordDeposit], which writes the new
/// balance and the ledger entry inside one Firestore transaction so they can't
/// drift apart. Feature UIs (Dev B's dashboard/deposit/transactions) consume the
/// streams and call [recordDeposit]; they should not write these docs directly.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _txCollection(String uid) =>
      _userDoc(uid).collection('transactions');

  /// Creates the profile doc on first sign-up. Idempotent: if the doc already
  /// exists (e.g. a re-run) it leaves the balance untouched.
  Future<void> createProfileIfAbsent({
    required String uid,
    required String email,
    String? displayName,
    double initialBalance = 0,
  }) async {
    final ref = _userDoc(uid);
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set(
      UserProfile.initialData(
        // Store lower-cased so transfer-by-email lookups always match.
        email: email.trim().toLowerCase(),
        displayName: displayName,
        initialBalance: initialBalance,
      ),
    );
  }

  /// Live profile (null until the doc exists).
  Stream<UserProfile?> profileStream(String uid) {
    return _userDoc(
      uid,
    ).snapshots().map((doc) => doc.exists ? UserProfile.fromDoc(doc) : null);
  }

  /// Live balance only — convenient for the dashboard balance card.
  Stream<double> balanceStream(String uid) {
    return _userDoc(uid).snapshots().map(
      (doc) => (doc.data()?['balance'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Most-recent-first ledger stream.
  Stream<List<BankTransaction>> transactionsStream(String uid) {
    return _txCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map(BankTransaction.fromDoc).toList());
  }

  /// Loads the quiz question bank (`quiz_questions`). The quiz feature (Dev C)
  /// shuffles and picks a subset per game.
  Future<List<QuizQuestion>> fetchQuizQuestions() async {
    final snap = await _db.collection('quiz_questions').get();
    return snap.docs.map(QuizQuestion.fromDoc).toList();
  }

  /// Atomically credits [amount] to the balance and appends a ledger entry.
  /// Returns the new balance.
  Future<double> recordDeposit({
    required String uid,
    required double amount,
    String description = 'Deposit',
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be greater than zero');
    }
    final userRef = _userDoc(uid);
    final txRef = _txCollection(uid).doc();

    return _db.runTransaction<double>((txn) async {
      final snap = await txn.get(userRef);
      final current = (snap.data()?['balance'] as num?)?.toDouble() ?? 0;
      final next = current + amount;

      // Use set-with-merge (not update) so a deposit succeeds even if the
      // profile doc doesn't exist yet — it creates the balance field and leaves
      // any existing profile fields (email, displayName) untouched.
      txn.set(userRef, {'balance': next}, SetOptions(merge: true));
      txn.set(txRef, {
        'amount': amount,
        'type': TransactionType.deposit.name,
        'description': description,
        'balanceAfter': next,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return next;
    });
  }

  // ---- Peer-to-peer transfers ----------------------------------------------

  /// Atomically moves [amount] from [fromUid] to the account registered under
  /// [toEmail]. Writes a withdrawal entry for the sender and a deposit entry for
  /// the recipient. Throws [BankingException] with a user-facing message on any
  /// validation failure (no such recipient, self-transfer, insufficient funds).
  Future<void> transfer({
    required String fromUid,
    required String toEmail,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw const BankingException('Enter an amount greater than zero.');
    }
    final email = toEmail.trim().toLowerCase();

    // Recipient lookup must run as a normal query (transactions can't query).
    final match = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (match.docs.isEmpty) {
      throw const BankingException('No account found with that email.');
    }
    final recipientRef = match.docs.first.reference;
    if (recipientRef.id == fromUid) {
      throw const BankingException("You can't transfer to yourself.");
    }

    final senderRef = _userDoc(fromUid);
    final senderTxRef = _txCollection(fromUid).doc();
    final recipientTxRef = recipientRef.collection('transactions').doc();

    await _db.runTransaction((txn) async {
      final senderSnap = await txn.get(senderRef);
      final recipientSnap = await txn.get(recipientRef);

      final senderBal =
          (senderSnap.data()?['balance'] as num?)?.toDouble() ?? 0;
      if (senderBal < amount) {
        throw const BankingException('Insufficient balance for this transfer.');
      }
      final recipientBal =
          (recipientSnap.data()?['balance'] as num?)?.toDouble() ?? 0;
      final senderNext = senderBal - amount;
      final recipientNext = recipientBal + amount;

      txn.set(senderRef, {'balance': senderNext}, SetOptions(merge: true));
      txn.set(recipientRef, {
        'balance': recipientNext,
      }, SetOptions(merge: true));
      txn.set(senderTxRef, {
        'amount': amount,
        'type': TransactionType.withdrawal.name,
        'description': 'Transfer to $email',
        'balanceAfter': senderNext,
        'createdAt': FieldValue.serverTimestamp(),
      });
      txn.set(recipientTxRef, {
        'amount': amount,
        'type': TransactionType.deposit.name,
        'description': 'Transfer received',
        'balanceAfter': recipientNext,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ---- Savings goals ("pots") ----------------------------------------------

  Stream<List<SavingsGoal>> goalsStream(String uid) {
    return _userDoc(uid)
        .collection('goals')
        .orderBy('createdAt')
        .snapshots()
        .map((q) => q.docs.map(SavingsGoal.fromDoc).toList());
  }

  Future<void> createGoal({
    required String uid,
    required String name,
    required double target,
  }) {
    return _userDoc(uid).collection('goals').add({
      'name': name.trim(),
      'target': target,
      'saved': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Moves [amount] from the main balance into the goal (atomic).
  Future<void> addToGoal({
    required String uid,
    required String goalId,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw const BankingException('Enter an amount greater than zero.');
    }
    final userRef = _userDoc(uid);
    final goalRef = userRef.collection('goals').doc(goalId);
    await _db.runTransaction((txn) async {
      final u = await txn.get(userRef);
      final g = await txn.get(goalRef);
      final bal = (u.data()?['balance'] as num?)?.toDouble() ?? 0;
      if (bal < amount) {
        throw const BankingException('Insufficient balance.');
      }
      final saved = (g.data()?['saved'] as num?)?.toDouble() ?? 0;
      txn.set(userRef, {'balance': bal - amount}, SetOptions(merge: true));
      txn.update(goalRef, {'saved': saved + amount});
    });
  }

  /// Moves [amount] from the goal back to the main balance (atomic).
  Future<void> withdrawFromGoal({
    required String uid,
    required String goalId,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw const BankingException('Enter an amount greater than zero.');
    }
    final userRef = _userDoc(uid);
    final goalRef = userRef.collection('goals').doc(goalId);
    await _db.runTransaction((txn) async {
      final u = await txn.get(userRef);
      final g = await txn.get(goalRef);
      final saved = (g.data()?['saved'] as num?)?.toDouble() ?? 0;
      if (saved < amount) {
        throw const BankingException('That goal does not hold that much.');
      }
      final bal = (u.data()?['balance'] as num?)?.toDouble() ?? 0;
      txn.set(userRef, {'balance': bal + amount}, SetOptions(merge: true));
      txn.update(goalRef, {'saved': saved - amount});
    });
  }

  /// Deletes a goal, refunding whatever it held back to the main balance.
  Future<void> deleteGoal({required String uid, required String goalId}) async {
    final userRef = _userDoc(uid);
    final goalRef = userRef.collection('goals').doc(goalId);
    await _db.runTransaction((txn) async {
      final u = await txn.get(userRef);
      final g = await txn.get(goalRef);
      final saved = (g.data()?['saved'] as num?)?.toDouble() ?? 0;
      final bal = (u.data()?['balance'] as num?)?.toDouble() ?? 0;
      txn.set(userRef, {'balance': bal + saved}, SetOptions(merge: true));
      txn.delete(goalRef);
    });
  }
}

/// A data-layer error whose [message] is safe to show directly in the UI.
class BankingException implements Exception {
  const BankingException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Single shared instance of the Firestore data layer.
final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

/// Live profile for a given uid.
final profileStreamProvider = StreamProvider.family<UserProfile?, String>(
  (ref, uid) => ref.watch(firestoreServiceProvider).profileStream(uid),
);

/// Live balance for a given uid.
final balanceStreamProvider = StreamProvider.family<double, String>(
  (ref, uid) => ref.watch(firestoreServiceProvider).balanceStream(uid),
);

/// Live ledger for a given uid.
final transactionsStreamProvider =
    StreamProvider.family<List<BankTransaction>, String>(
      (ref, uid) => ref.watch(firestoreServiceProvider).transactionsStream(uid),
    );

/// The full quiz question bank (loaded once per game).
final quizQuestionsProvider = FutureProvider<List<QuizQuestion>>(
  (ref) => ref.watch(firestoreServiceProvider).fetchQuizQuestions(),
);

/// Live savings goals for a given uid.
final goalsStreamProvider = StreamProvider.family<List<SavingsGoal>, String>(
  (ref, uid) => ref.watch(firestoreServiceProvider).goalsStream(uid),
);
