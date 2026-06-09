import 'package:cloud_firestore/cloud_firestore.dart';

/// The kind of money movement a transaction represents.
enum TransactionType {
  deposit,
  withdrawal;

  static TransactionType fromName(String? name) {
    return TransactionType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => TransactionType.deposit,
    );
  }
}

/// A single ledger entry, stored at `users/{uid}/transactions/{id}`.
///
/// Written atomically alongside the balance update in `FirestoreService` so the
/// running balance and the ledger can never drift apart. UI (Dev B) reads these;
/// it should not construct or write them directly.
class BankTransaction {
  const BankTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.balanceAfter,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final TransactionType type;
  final String description;
  final double balanceAfter;
  final DateTime createdAt;

  factory BankTransaction.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return BankTransaction(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: TransactionType.fromName(data['type'] as String?),
      description: (data['description'] as String?) ?? '',
      balanceAfter: (data['balanceAfter'] as num?)?.toDouble() ?? 0,
      // createdAt is null only for the brief window before the server timestamp
      // resolves; fall back to "now" so the UI never sees a null.
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
