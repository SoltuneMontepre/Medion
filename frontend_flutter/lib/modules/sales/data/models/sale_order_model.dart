import '../../domain/entities/sale_order.dart';

/// Data model with fromJson. Maps to domain entity.
class SaleOrderModel {
  const SaleOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.date,
    required this.totalAmount,
    required this.status,
  });

  final String id;
  final String orderNumber;
  final String customerName;
  final String date;
  final double totalAmount;
  final String status;

  factory SaleOrderModel.fromJson(Map<String, dynamic> json) {
    final orderDate = json['orderDate'];
    final dateStr = orderDate != null ? orderDate.toString() : (json['date'] as String? ?? '');
    return SaleOrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      date: dateStr,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? '',
    );
  }

  SaleOrder toEntity() => SaleOrder(
        id: id,
        orderNumber: orderNumber,
        customerName: customerName,
        date: date,
        totalAmount: totalAmount,
        status: status,
      );
}
