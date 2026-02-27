/// Domain entity. No Flutter, no JSON.
class Report {
  const Report({
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
}
