/// Domain entity. Maps to backend ProductionOrderPayload.
class ProductionOrder {
  const ProductionOrder({
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
}
