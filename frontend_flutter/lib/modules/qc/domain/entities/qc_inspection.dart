/// Domain entity. No Flutter, no JSON.
/// Corresponds to QualityControl.API backend.
class QcInspection {
  const QcInspection({
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
}
