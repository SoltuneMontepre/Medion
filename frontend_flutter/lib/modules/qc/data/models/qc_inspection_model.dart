import '../../domain/entities/qc_inspection.dart';

/// Data model with fromJson/toJson. Maps to domain entity.
class QcInspectionModel {
  const QcInspectionModel({
    required this.id,
    required this.batchNumber,
    required this.productName,
    required this.inspector,
    required this.result,
    required this.date,
    required this.notes,
  });

  final String id;
  final String batchNumber;
  final String productName;
  final String inspector;
  final String result;
  final String date;
  final String notes;

  factory QcInspectionModel.fromJson(Map<String, dynamic> json) {
    return QcInspectionModel(
      id: json['id'] as String? ?? '',
      batchNumber: json['batchNumber'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      inspector: json['inspector'] as String? ?? '',
      result: json['result'] as String? ?? '',
      date: json['date'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  QcInspection toEntity() => QcInspection(
        id: id,
        batchNumber: batchNumber,
        productName: productName,
        inspector: inspector,
        result: result,
        date: date,
        notes: notes,
      );
}
