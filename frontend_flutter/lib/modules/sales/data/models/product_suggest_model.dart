/// Product from suggest API for dropdown.
class ProductSuggestModel {
  const ProductSuggestModel({
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

  factory ProductSuggestModel.fromJson(Map<String, dynamic> json) {
    return ProductSuggestModel(
      id: json['id']?.toString() ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      packageSize: json['packageSize'] as String? ?? '',
      packageUnit: json['packageUnit'] as String? ?? '',
      productType: json['productType'] as String? ?? '',
      packagingType: json['packagingType'] as String? ?? '',
    );
  }

  String get specification =>
      '$packageSize$packageUnit'.replaceAll(RegExp(r'\s+'), '');
}
