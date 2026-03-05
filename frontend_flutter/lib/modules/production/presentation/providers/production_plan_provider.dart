import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/production_plan_remote_datasource_impl.dart';
import '../../domain/entities/production_plan.dart';

/// Bảng Kế hoạch Sản xuất (theo ngày). Fetches from API; date param is dd/MM/yyyy (display format).
final productionPlanProvider =
    FutureProvider.autoDispose.family<ProductionPlan, String>((ref, dateStr) async {
  final ds = ref.watch(productionPlanRemoteDataSourceProvider);
  final apiDate = _displayDateToApiDate(dateStr);
  final model = await ds.getByDate(apiDate);
  if (model == null) {
    return ProductionPlan(planDate: dateStr, items: []);
  }
  final plan = model.toEntity();
  return ProductionPlan(
    planDate: dateStr,
    items: plan.items,
    id: plan.id,
    status: plan.status,
  );
});

/// Converts dd/MM/yyyy to yyyy-MM-dd for API.
String _displayDateToApiDate(String ddMmYyyy) {
  final parts = ddMmYyyy.split('/');
  if (parts.length != 3) return ddMmYyyy;
  return '${parts[2]}-${parts[1]}-${parts[0]}';
}
