import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories_impl/sales_repository_impl.dart';
import '../../domain/entities/order_summary.dart';

/// List order summaries for current sale admin (paginated).
final orderSummaryListProvider = FutureProvider.autoDispose
    .family<OrderSummaryListResult, ({int page, int pageSize})>((ref, params) async {
  final repository = ref.watch(salesRepositoryProvider);
  return repository.getOrderSummaries(
    page: params.page,
    pageSize: params.pageSize,
  );
});

/// Order summary for a given date (e.g. today). [date] yyyy-MM-dd.
final orderSummaryByDateProvider =
    FutureProvider.autoDispose.family<OrderSummary?, String>((ref, date) async {
  final repository = ref.watch(salesRepositoryProvider);
  final dateYyyyMmDd = _toYyyyMmDd(date);
  return repository.getOrderSummaryByDate(dateYyyyMmDd);
});

/// Order summary by id.
final orderSummaryByIdProvider =
    FutureProvider.autoDispose.family<OrderSummary?, String>((ref, id) async {
  final repository = ref.watch(salesRepositoryProvider);
  return repository.getOrderSummaryById(id);
});

/// Converts 'dd/MM/yyyy' to 'yyyy-MM-dd', or returns [date] if already yyyy-MM-dd.
String _toYyyyMmDd(String date) {
  final parts = date.split('/');
  if (parts.length == 3) {
    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];
    return '$year-$month-$day';
  }
  return date;
}

/// Format DateTime to yyyy-MM-dd for API.
String formatDateToYyyyMmDd(DateTime d) {
  final y = d.year;
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
