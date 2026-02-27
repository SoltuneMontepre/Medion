/// Domain entity. No Flutter, no JSON.
/// Bảng Kế hoạch Sản xuất: ngày lập, danh sách SP (MÃ SP, TÊN SP, QUY CÁCH, DẠNG, DẠNG ĐÓNG GÓI, SỐ).
class ProductionPlanItem {
  const ProductionPlanItem({
    required this.ordinal,
    required this.productCode,
    required this.productName,
    required this.specification,
    required this.productForm,
    required this.packagingForm,
    required this.plannedQuantity,
  });

  final int ordinal;
  final String productCode;
  final String productName;
  final String specification;
  final String productForm;
  final String packagingForm;
  final int plannedQuantity;
}

class ProductionPlan {
  const ProductionPlan({
    required this.planDate,
    required this.items,
  });

  final String planDate;
  final List<ProductionPlanItem> items;
}
