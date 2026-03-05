import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/finished_product_release.dart';
import '../../data/datasources/finished_product_dispatch_remote_datasource_impl.dart';

/// Phiếu Xuất kho Thành phẩm — list from API. [statusFilter] null or empty = all.
final finishedProductReleasesProvider =
    FutureProvider.autoDispose.family<({List<FinishedProductRelease> items, int total}), String?>(
        (ref, statusFilter) async {
  final ds = ref.watch(finishedProductDispatchRemoteDataSourceProvider);
  final result = await ds.list(
    status: statusFilter?.isEmpty == true ? null : statusFilter,
    limit: 50,
    offset: 0,
  );
  return (
    items: result.items.map((e) => e.toEntity()).toList(),
    total: result.total,
  );
});

/// Single dispatch by id.
final finishedProductReleaseByIdProvider =
    FutureProvider.autoDispose.family<FinishedProductRelease?, String>((ref, id) async {
  final ds = ref.watch(finishedProductDispatchRemoteDataSourceProvider);
  final model = await ds.getById(id);
  return model?.toEntity();
});
