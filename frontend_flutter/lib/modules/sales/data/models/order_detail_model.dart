/// Order detail from API (create response or get by id).
class OrderDetailModel {
  const OrderDetailModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerCode,
    required this.customerName,
    required this.orderDate,
    required this.status,
    required this.items,
  });

  final String id;
  final String orderNumber;
  final String customerId;
  final String customerCode;
  final String customerName;
  final String orderDate;
  final String status;
  final List<OrderItemDetailModel> items;

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return OrderDetailModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerCode: json['customerCode'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      orderDate: json['orderDate'] as String? ?? '',
      status: json['status'] as String? ?? '',
      items: itemsList
          .whereType<Map<String, dynamic>>()
          .map(OrderItemDetailModel.fromJson)
          .toList(),
    );
  }
}

class OrderItemDetailModel {
  const OrderItemDetailModel({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.packageSize,
    required this.packageUnit,
    required this.productType,
    required this.packagingType,
    required this.quantity,
  });

  final String productId;
  final String productCode;
  final String productName;
  final String packageSize;
  final String packageUnit;
  final String productType;
  final String packagingType;
  final int quantity;

  factory OrderItemDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderItemDetailModel(
      productId: json['productId']?.toString() ?? '',
      productCode: json['productCode'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      packageSize: json['packageSize'] as String? ?? '',
      packageUnit: json['packageUnit'] as String? ?? '',
      productType: json['productType'] as String? ?? '',
      packagingType: json['packagingType'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  /// Quy cách display: e.g. "100gr"
  String get specification =>
      '$packageSize$packageUnit'.replaceAll(RegExp(r'\s+'), '');
}
