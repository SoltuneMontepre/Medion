/// Domain entity. No Flutter, no JSON.
/// Bảng Tổng hợp Đơn đặt hàng: read-only, scoped by sale admin (owner).
class OrderSummaryItem {
  const OrderSummaryItem({
    required this.productCode,
    required this.productName,
    required this.packageSize,
    required this.packageUnit,
    required this.productType,
    required this.packagingType,
    required this.quantity,
  });

  final String productCode;
  final String productName;
  final String packageSize;
  final String packageUnit;
  final String productType;
  final String packagingType;
  final int quantity;

  /// Quy cách = packageSize + packageUnit (e.g. 100gr).
  String get specification => '$packageSize$packageUnit';

  /// Dạng = productType; Đóng gói = packagingType.
}

/// Detail view (with items). From GET by-date or GET by-id.
class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.ownerId,
    required this.summaryDate,
    required this.createdAt,
    this.approvedBy,
    required this.items,
  });

  final String id;
  final String ownerId;
  final String summaryDate; // ISO date or yyyy-MM-dd
  final DateTime createdAt;
  final String? approvedBy;
  final List<OrderSummaryItem> items;
}

/// List entry (no items). From GET order-summaries.
class OrderSummaryListEntry {
  const OrderSummaryListEntry({
    required this.id,
    required this.ownerId,
    required this.summaryDate,
    required this.createdAt,
    required this.itemCount,
  });

  final String id;
  final String ownerId;
  final String summaryDate;
  final DateTime createdAt;
  final int itemCount;
}

/// Paginated list result for order summaries.
class OrderSummaryListResult {
  const OrderSummaryListResult({
    required this.items,
    required this.total,
  });
  final List<OrderSummaryListEntry> items;
  final int total;
}
