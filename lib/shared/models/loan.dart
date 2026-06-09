import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

enum LoanStatus {
  active,
  paid;

  static LoanStatus fromName(String? name) => LoanStatus.values.firstWhere(
    (s) => s.name == name,
    orElse: () => LoanStatus.active,
  );
}

/// A loan, stored at `users/{uid}/loans/{id}`. The principal is disbursed to the
/// balance on approval; [outstanding] is the remaining amount to repay (which
/// includes interest).
class Loan {
  const Loan({
    required this.id,
    required this.principal,
    required this.termMonths,
    required this.ratePct,
    required this.totalRepayable,
    required this.outstanding,
    required this.monthlyPayment,
    required this.purpose,
    required this.status,
    this.createdAt,
  });

  final String id;
  final double principal;
  final int termMonths;
  final double ratePct;
  final double totalRepayable;
  final double outstanding;
  final double monthlyPayment;
  final String purpose;
  final LoanStatus status;
  final DateTime? createdAt;

  bool get isActive => status == LoanStatus.active;

  /// 0..1 repaid.
  double get progress => totalRepayable <= 0
      ? 0
      : (1 - outstanding / totalRepayable).clamp(0.0, 1.0);

  factory Loan.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Loan(
      id: doc.id,
      principal: (data['principal'] as num?)?.toDouble() ?? 0,
      termMonths: (data['termMonths'] as num?)?.toInt() ?? 1,
      ratePct: (data['ratePct'] as num?)?.toDouble() ?? 0,
      totalRepayable: (data['totalRepayable'] as num?)?.toDouble() ?? 0,
      outstanding: (data['outstanding'] as num?)?.toDouble() ?? 0,
      monthlyPayment: (data['monthlyPayment'] as num?)?.toDouble() ?? 0,
      purpose: (data['purpose'] as String?) ?? '',
      status: LoanStatus.fromName(data['status'] as String?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Outcome of a loan eligibility check — drives both the live preview and the
/// actual application.
class LoanDecision {
  const LoanDecision({
    required this.approved,
    required this.maxEligible,
    this.reason,
    this.amount = 0,
    this.ratePct = 0,
    this.monthlyPayment = 0,
    this.totalRepayable = 0,
    this.creditScore = 0,
    this.termMonths = 0,
  });

  final bool approved;
  final String? reason;
  final double maxEligible;
  final double amount;
  final double ratePct;
  final double monthlyPayment;
  final double totalRepayable;
  final int creditScore;
  final int termMonths;
}

/// Pure eligibility + pricing logic, shared by the live preview and the apply
/// flow. Approval is intentionally lightweight (income + affordability +
/// eligibility cap); the credit score is used only to pick the flat rate band.
LoanDecision evaluateLoan({
  required double requestedAmount,
  required int termMonths,
  required double monthlyIncome,
  required double totalDeposited,
  required double currentBalance,
  required int accountAgeDays,
  required bool hasActiveLoan,
}) {
  // Max you can borrow, from income and demonstrated account activity.
  final maxEligible = [
    3 * monthlyIncome,
    0.5 * totalDeposited + currentBalance,
    500000.0, // hard cap
  ].reduce(min).floorToDouble();

  // Credit score (0–100) → only sets the rate band.
  var score = 0;
  score += monthlyIncome >= 100000
      ? 30
      : monthlyIncome >= 50000
      ? 20
      : monthlyIncome > 0
      ? 10
      : 0;
  score += totalDeposited >= 100000
      ? 25
      : totalDeposited >= 20000
      ? 15
      : 5;
  score += accountAgeDays >= 30
      ? 15
      : accountAgeDays >= 7
      ? 10
      : 5;
  score += currentBalance >= 50000
      ? 10
      : currentBalance > 0
      ? 5
      : 0;
  score += hasActiveLoan ? 0 : 20; // clean slate
  score = score.clamp(0, 100);

  final ratePct = score >= 80
      ? 5.0
      : score >= 60
      ? 8.0
      : 12.0;

  final total = requestedAmount * (1 + (ratePct / 100) * (termMonths / 12));
  final monthly = termMonths > 0 ? total / termMonths : total;

  String? deny;
  if (hasActiveLoan) {
    deny = 'You already have an active loan. Repay it first.';
  } else if (monthlyIncome <= 0) {
    deny = 'Enter a valid monthly income.';
  } else if (requestedAmount <= 0) {
    deny = 'Enter an amount to borrow.';
  } else if (requestedAmount > maxEligible) {
    deny = 'That exceeds what you qualify for right now.';
  } else if (monthly > 0.4 * monthlyIncome) {
    deny =
        'The monthly repayment is too high for your income — '
        'try a smaller amount or a longer term.';
  }

  if (deny != null) {
    return LoanDecision(
      approved: false,
      reason: deny,
      maxEligible: maxEligible,
      creditScore: score,
    );
  }

  return LoanDecision(
    approved: true,
    maxEligible: maxEligible,
    amount: requestedAmount,
    ratePct: ratePct,
    monthlyPayment: monthly,
    totalRepayable: total,
    creditScore: score,
    termMonths: termMonths,
  );
}
