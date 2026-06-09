import 'package:cloud_firestore/cloud_firestore.dart';

/// A savings goal / "pot", stored at `users/{uid}/goals/{id}`.
/// Money moved into a goal is debited from the main balance, so `saved` and the
/// account balance always reconcile.
class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.target,
    required this.saved,
    this.createdAt,
  });

  final String id;
  final String name;
  final double target;
  final double saved;
  final DateTime? createdAt;

  /// 0..1 completion, safe when target is 0.
  double get progress => target <= 0 ? 0 : (saved / target).clamp(0.0, 1.0);

  bool get isComplete => saved >= target && target > 0;

  factory SavingsGoal.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return SavingsGoal(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      target: (data['target'] as num?)?.toDouble() ?? 0,
      saved: (data['saved'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
