/// Tồn kho hiện tại: one row per product in a warehouse (raw / semi / finished).
class InventoryBalance {
  const InventoryBalance({
    required this.id,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.packageSize,
    required this.packageUnit,
    required this.productType,
    required this.packagingType,
    required this.warehouseType,
    required this.quantity,
  });

  final String id;
  final String productId;
  final String productCode;
  final String productName;
  final String packageSize;
  final String packageUnit;
  final String productType;
  final String packagingType;
  final String warehouseType;
  final int quantity;
}
