import '../../domain/entities/inventory_balance.dart';

class InventoryBalanceModel {
  const InventoryBalanceModel({
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

  factory InventoryBalanceModel.fromJson(Map<String, dynamic> json) {
    return InventoryBalanceModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productCode: json['productCode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      packageSize: json['packageSize'] as String? ?? '',
      packageUnit: json['packageUnit'] as String? ?? '',
      productType: json['productType'] as String? ?? '',
      packagingType: json['packagingType'] as String? ?? '',
      warehouseType: json['warehouseType'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  InventoryBalance toEntity() => InventoryBalance(
        id: id,
        productId: productId,
        productCode: productCode,
        productName: productName,
        packageSize: packageSize,
        packageUnit: packageUnit,
        productType: productType,
        packagingType: packagingType,
        warehouseType: warehouseType,
        quantity: quantity,
      );
}
