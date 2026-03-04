/// Domain entity for a product. No Flutter, no JSON.
class Product {
  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.packageSize,
    required this.packageUnit,
    required this.productType,
    required this.packagingType,
  });

  final String id;
  final String code;
  final String name;
  final String packageSize;
  final String packageUnit;
  final String productType;
  final String packagingType;

  /// Quy cách: e.g. "100gr"
  String get specification =>
      '$packageSize$packageUnit'.replaceAll(RegExp(r'\s+'), '');
}

/// Params for create/update product (domain).
class ProductMutationParams {
  const ProductMutationParams({
    required this.code,
    required this.name,
    required this.packageSize,
    required this.packageUnit,
    required this.productType,
    required this.packagingType,
  });
  final String code;
  final String name;
  final String packageSize;
  final String packageUnit;
  final String productType;
  final String packagingType;
}
