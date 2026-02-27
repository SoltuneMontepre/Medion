import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/qc_inspection.dart';
import '../../domain/usecases/get_qc_inspections.dart';
import '../../data/repositories_impl/qc_repository_impl.dart';

/// Async state: loading/error/data. Scoped per module.
final qcInspectionsProvider =
    FutureProvider.autoDispose.family<List<QcInspection>, int>((ref, page) {
  final repository = ref.watch(qcRepositoryProvider);
  final useCase = GetQcInspections(repository);
  return useCase(page: page, pageSize: 20);
});
