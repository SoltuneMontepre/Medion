import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/sale_order.dart';
import '../../domain/usecases/get_sales_orders.dart';
import '../../data/repositories_impl/sales_repository_impl.dart';

/// Async state: loading/error/data. Refetches when [OrdersListQuery] changes (page, filters, sort).
final salesOrdersProvider = FutureProvider.autoDispose
    .family<SaleOrdersListResult, OrdersListQuery>((ref, query) {
  final repository = ref.watch(salesRepositoryProvider);
  final useCase = GetSalesOrders(repository);
  return useCase(query);
});
