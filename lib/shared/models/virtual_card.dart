import 'package:cloud_firestore/cloud_firestore.dart';

/// A (simulated) virtual card for online payments, stored at
/// `users/{uid}/cards/{id}`. The number is Luhn-valid but not a real PAN — real
/// virtual cards require a card-issuing provider (e.g. Stripe Issuing).
class VirtualCard {
  const VirtualCard({
    required this.id,
    required this.number,
    required this.holder,
    required this.expMonth,
    required this.expYear,
    required this.cvv,
    required this.frozen,
    this.createdAt,
  });

  final String id;
  final String number; // 16 digits
  final String holder;
  final int expMonth;
  final int expYear;
  final String cvv;
  final bool frozen;
  final DateTime? createdAt;

  String get last4 =>
      number.length >= 4 ? number.substring(number.length - 4) : number;

  String get masked => '••••  ••••  ••••  $last4';

  /// "4276 1234 5678 9010"
  String get formatted {
    final b = StringBuffer();
    for (var i = 0; i < number.length; i++) {
      if (i > 0 && i % 4 == 0) b.write('  ');
      b.write(number[i]);
    }
    return b.toString();
  }

  String get expiry =>
      '${expMonth.toString().padLeft(2, '0')}/${(expYear % 100).toString().padLeft(2, '0')}';

  factory VirtualCard.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return VirtualCard(
      id: doc.id,
      number: (data['number'] as String?) ?? '',
      holder: (data['holder'] as String?) ?? '',
      expMonth: (data['expMonth'] as num?)?.toInt() ?? 1,
      expYear: (data['expYear'] as num?)?.toInt() ?? 2030,
      cvv: (data['cvv'] as String?) ?? '•••',
      frozen: (data['frozen'] as bool?) ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
