/// Domain entity. No Flutter, no JSON.
/// Corresponds to Manufacture.API backend.
class ProductionOrder {
  const ProductionOrder({
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
}
