import 'package:cloud_firestore/cloud_firestore.dart';

/// A user's banking profile, stored at `users/{uid}` in Firestore.
///
/// `balance` is the source of truth for the account balance and is mutated only
/// through transactional writes in `FirestoreService` (never set directly from
/// UI), so it always stays consistent with the `transactions` subcollection.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.balance,
    this.displayName,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String? displayName;
  final double balance;
  final DateTime? createdAt;

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return UserProfile(
      uid: doc.id,
      email: (data['email'] as String?) ?? '',
      displayName: data['displayName'] as String?,
      balance: (data['balance'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Field map used to seed a brand-new profile on sign-up.
  static Map<String, dynamic> initialData({
    required String email,
    String? displayName,
    double initialBalance = 0,
  }) {
    return {
      'email': email,
      'displayName': displayName,
      'balance': initialBalance,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
