import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories_impl/sales_repository_impl.dart';
import '../../domain/entities/order_summary.dart';

/// Bảng Tổng hợp Đơn đặt hàng (theo ngày). Uses Sale API GET /api/sale/orders/daily-summary.
/// [date] can be 'dd/MM/yyyy' (from UI) or 'yyyy-MM-dd'; we send yyyy-MM-dd to the API.
final orderSummaryProvider =
    FutureProvider.autoDispose.family<OrderSummary, String>((ref, date) async {
  final repository = ref.watch(salesRepositoryProvider);
  final dateYyyyMmDd = _toYyyyMmDd(date);
  return repository.getOrderSummary(dateYyyyMmDd);
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
