import '../../domain/entities/payroll_record.dart';

/// Data model with fromJson. Maps to domain entity.
class PayrollRecordModel {
  const PayrollRecordModel({
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

  factory PayrollRecordModel.fromJson(Map<String, dynamic> json) {
    return PayrollRecordModel(
      id: json['id'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      period: json['period'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? '',
    );
  }

  PayrollRecord toEntity() => PayrollRecord(
        id: id,
        employeeName: employeeName,
        period: period,
        amount: amount,
        status: status,
      );
}
