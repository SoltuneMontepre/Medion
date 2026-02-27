/// Domain entity. No Flutter, no JSON.
/// Bảng Tổng hợp Đơn đặt hàng: tổng hợp theo MÃ SP từ tất cả đơn hàng trong ngày.
class OrderSummaryItem {
  const OrderSummaryItem({
    required this.ordinal,
    required this.productCode,
    required this.productName,
    required this.specification,
    required this.productForm,
    required this.packagingForm,
    required this.totalQuantity,
  });

  final int ordinal;
  final String productCode;
  final String productName;
  final String specification;
  final String productForm;
  final String packagingForm;
  final int totalQuantity;
}

class OrderSummary {
  const OrderSummary({
    required this.summaryDate,
    required this.items,
  });

  final String summaryDate;
  final List<OrderSummaryItem> items;
}
