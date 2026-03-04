import '../../domain/entities/product.dart';

class ProductModel {
  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      packageSize: json['packageSize'] as String? ?? '',
      packageUnit: json['packageUnit'] as String? ?? '',
      productType: json['productType'] as String? ?? '',
      packagingType: json['packagingType'] as String? ?? '',
    );
  }

  Product toEntity() => Product(
        id: id,
        code: code,
        name: name,
        packageSize: packageSize,
        packageUnit: packageUnit,
        productType: productType,
        packagingType: packagingType,
      );
}
