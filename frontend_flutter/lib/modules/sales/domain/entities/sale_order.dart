/// Domain entity. No Flutter, no JSON.
class SaleOrder {
  const SaleOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.date,
    required this.totalAmount,
    required this.status,
    this.responsiblePerson,
  });

  final String id;
  final String orderNumber;
  final String customerName;
  final String date;
  final double totalAmount;
  final String status;
  /// Phụ trách (responsible person) — optional from API.
  final String? responsiblePerson;
}

/// Query params for listing orders (aligned with backend GET /api/v1/sale/orders).
class OrdersListQuery {
  const OrdersListQuery({
    this.page = 1,
    this.pageSize = 20,
    this.search = '',
    this.dateFilter,
    this.status = '',
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
  });
  final int page;
  final int pageSize;
  final String search;
  /// 'today' | 'week' | 'month'
  final String? dateFilter;
  final String status;
  /// 'created_at' | 'order_date' | 'order_number'
  final String sortBy;
  /// 'asc' | 'desc'
  final String sortOrder;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrdersListQuery &&
          page == other.page &&
          pageSize == other.pageSize &&
          search == other.search &&
          dateFilter == other.dateFilter &&
          status == other.status &&
          sortBy == other.sortBy &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      Object.hash(page, pageSize, search, dateFilter, status, sortBy, sortOrder);
}

/// Result of GET /api/v1/sale/orders (paginated, filtered, sorted).
class SaleOrdersListResult {
  const SaleOrdersListResult({required this.items, required this.total});
  final List<SaleOrder> items;
  final int total;
}
