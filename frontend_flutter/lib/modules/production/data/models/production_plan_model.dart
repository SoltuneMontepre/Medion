import '../../domain/entities/production_plan.dart';

/// Parses API payload (ProductionPlanPayload) to domain entity.
class ProductionPlanModel {
  const ProductionPlanModel({
    required this.planDate,
    required this.items,
    this.id,
    this.status,
    this.planDateYyyyMmDd,
  });

  final String planDate;
  final List<ProductionPlanItemModel> items;
  final String? id;
  final String? status;
  /// YYYY-MM-DD for API (create/update).
  final String? planDateYyyyMmDd;

  factory ProductionPlanModel.fromJson(Map<String, dynamic> json) {
    final planDateRaw = json['planDate'] as String? ?? '';
    final planDate = _formatPlanDate(planDateRaw);
    final planDateYyyyMmDd = planDateRaw.isNotEmpty ? planDateRaw.split('T').first : null;
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((e) => ProductionPlanItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final id = json['id']?.toString();
    final status = json['status'] as String?;
    return ProductionPlanModel(planDate: planDate, items: items, id: id, status: status, planDateYyyyMmDd: planDateYyyyMmDd);
  }

  static String _formatPlanDate(String isoOrYyyyMmDd) {
    if (isoOrYyyyMmDd.isEmpty) return '';
    final s = isoOrYyyyMmDd.split('T').first;
    final parts = s.split('-');
    if (parts.length != 3) return s;
    final day = parts[2];
    final month = parts[1];
    final year = parts[0];
    return '$day/$month/$year';
  }

  ProductionPlan toEntity() => ProductionPlan(
        planDate: planDate,
        items: items.map((e) => e.toEntity()).toList(),
        id: id,
        status: status,
      );
}

class ProductionPlanItemModel {
  const ProductionPlanItemModel({
    required this.ordinal,
    required this.productCode,
    required this.productName,
    required this.specification,
    required this.productForm,
    required this.packagingForm,
    required this.plannedQuantity,
    this.productId,
  });

  final int ordinal;
  final String productCode;
  final String productName;
  final String specification;
  final String productForm;
  final String packagingForm;
  final int plannedQuantity;
  final String? productId;

  factory ProductionPlanItemModel.fromJson(Map<String, dynamic> json) {
    return ProductionPlanItemModel(
      ordinal: (json['ordinal'] as num?)?.toInt() ?? 0,
      productCode: json['productCode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      specification: json['specification'] as String? ?? '',
      productForm: json['productForm'] as String? ?? '',
      packagingForm: json['packagingForm'] as String? ?? '',
      plannedQuantity: (json['plannedQuantity'] as num?)?.toInt() ?? 0,
      productId: json['productId']?.toString(),
    );
  }

  ProductionPlanItem toEntity() => ProductionPlanItem(
        ordinal: ordinal,
        productCode: productCode,
        productName: productName,
        specification: specification,
        productForm: productForm,
        packagingForm: packagingForm,
        plannedQuantity: plannedQuantity,
      );
}
