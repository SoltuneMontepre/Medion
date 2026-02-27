import '../../domain/entities/report.dart';

/// Data model with fromJson/toJson. Maps to domain entity.
class ReportModel {
  const ReportModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.date,
    required this.createdBy,
  });

  final String id;
  final String title;
  final String type;
  final String status;
  final String date;
  final String createdBy;

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      date: json['date'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
    );
  }

  Report toEntity() => Report(
        id: id,
        title: title,
        type: type,
        status: status,
        date: date,
        createdBy: createdBy,
      );
}
