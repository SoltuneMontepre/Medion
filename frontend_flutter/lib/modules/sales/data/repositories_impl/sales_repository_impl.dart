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
  Future<List<SaleOrder>> getOrders({int page = 1, int pageSize = 20}) async {
    final models = await _dataSource.fetchOrders(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<OrderSummary> getOrderSummary(String dateYyyyMmDd) async {
    return _dataSource.fetchDailyOrderSummary(dateYyyyMmDd);
  }
}

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final dataSource = ref.watch(salesRemoteDataSourceProvider);
  return SalesRepositoryImpl(dataSource);
});
