import '../../domain/entities/production_order.dart';

/// Data model with fromJson. Maps to domain entity.
class ProductionOrderModel {
  const ProductionOrderModel({
    required this.id,
    required this.orderNumber,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.date,
  });

  final String id;
  final String orderNumber;
  final String productName;
  final int quantity;
  final String status;
  final String date;

  factory ProductionOrderModel.fromJson(Map<String, dynamic> json) {
    return ProductionOrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }

  ProductionOrder toEntity() => ProductionOrder(
        id: id,
        orderNumber: orderNumber,
        productName: productName,
        quantity: quantity,
        status: status,
        date: date,
      );
}
