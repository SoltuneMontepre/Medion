/// Domain entity. No Flutter, no JSON.
class SaleOrder {
  const SaleOrder({
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
}
