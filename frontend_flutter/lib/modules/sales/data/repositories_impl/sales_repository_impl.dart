import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order_summary.dart';
import '../../domain/entities/sale_order.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_datasource.dart';
import '../datasources/sales_remote_datasource_impl.dart';

class SalesRepositoryImpl implements SalesRepository {
  SalesRepositoryImpl(this._dataSource);

  final SalesRemoteDataSource _dataSource;

  @override
  Future<SaleOrdersListResult> getOrders(OrdersListQuery query) async {
    final response = await _dataSource.fetchOrders(query);
    final items = response.items.map((m) => m.toEntity()).toList();
    return SaleOrdersListResult(items: items, total: response.total);
  }

  @override
  Future<OrderSummaryListResult> getOrderSummaries({
    int page = 1,
    int pageSize = 20,
  }) async {
    return _dataSource.fetchOrderSummaries(
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<OrderSummary?> getOrderSummaryByDate(String dateYyyyMmDd) async {
    return _dataSource.fetchOrderSummaryByDate(dateYyyyMmDd);
  }

  @override
  Future<OrderSummary?> getOrderSummaryById(String id) async {
    return _dataSource.fetchOrderSummaryById(id);
  }
}

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final dataSource = ref.watch(salesRemoteDataSourceProvider);
  return SalesRepositoryImpl(dataSource);
});
