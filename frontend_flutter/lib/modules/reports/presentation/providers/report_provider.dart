import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/report.dart';
import '../../domain/usecases/get_reports.dart';
import '../../data/repositories_impl/report_repository_impl.dart';

/// Async state: loading/error/data. Scoped per module.
final reportsProvider =
    FutureProvider.autoDispose.family<List<Report>, int>((ref, page) {
  final repository = ref.watch(reportRepositoryProvider);
  final useCase = GetReports(repository);
  return useCase(page: page, pageSize: 20);
});
