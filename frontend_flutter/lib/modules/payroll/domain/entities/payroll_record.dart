/// Domain entity. No Flutter, no JSON.
/// Corresponds to Payroll.API backend.
class PayrollRecord {
  const PayrollRecord({
    required this.id,
    required this.employeeName,
    required this.period,
    required this.amount,
    required this.status,
  });

  final String id;
  final String employeeName;
  final String period;
  final double amount;
  final String status;
}
