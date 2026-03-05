import '../../domain/entities/production_order.dart';

/// Data model with fromJson. Maps to domain entity.
class ProductionOrderModel {
  const ProductionOrderModel({
    required this.id,
    required this.orderNumber,
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.productForm,
    required this.specification,
    required this.batchNumber,
    required this.productionDate,
    required this.expiryDate,
    required this.batchSizeLit,
    required this.quantitySpec1,
    required this.quantitySpec2,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String productId;
  final String productCode;
  final String productName;
  final String productForm;
  final String specification;
  final String batchNumber;
  final String productionDate;
  final String expiryDate;
  final double batchSizeLit;
  final int quantitySpec1;
  final int quantitySpec2;
  final String status;
  final String createdAt;

  factory ProductionOrderModel.fromJson(Map<String, dynamic> json) {
    final prodDate = json['productionDate'] as String?;
    final expDate = json['expiryDate'] as String?;
    final created = json['createdAt'] as String?;
    return ProductionOrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      productId: json['productId']?.toString() ?? '',
      productCode: json['productCode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      productForm: json['productForm'] as String? ?? '',
      specification: json['specification'] as String? ?? '',
      batchNumber: json['batchNumber'] as String? ?? '',
      productionDate: prodDate != null ? prodDate.split('T').first : '',
      expiryDate: expDate != null ? expDate.split('T').first : '',
      batchSizeLit: (json['batchSizeLit'] as num?)?.toDouble() ?? 0,
      quantitySpec1: json['quantitySpec1'] as int? ?? 0,
      quantitySpec2: json['quantitySpec2'] as int? ?? 0,
      status: json['status'] as String? ?? 'draft',
      createdAt: created != null ? created.split('T').first : '',
    );
  }

  ProductionOrder toEntity() => ProductionOrder(
        id: id,
        orderNumber: orderNumber,
        productId: productId,
        productCode: productCode,
        productName: productName,
        productForm: productForm,
        specification: specification,
        batchNumber: batchNumber,
        productionDate: productionDate,
        expiryDate: expiryDate,
        batchSizeLit: batchSizeLit,
        quantitySpec1: quantitySpec1,
        quantitySpec2: quantitySpec2,
        status: status,
        createdAt: createdAt,
      );
}
