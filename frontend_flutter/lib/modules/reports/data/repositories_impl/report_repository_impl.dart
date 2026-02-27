import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';
import '../datasources/report_remote_datasource_impl.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._dataSource);

  final ReportRemoteDataSource _dataSource;

  @override
  Future<List<Report>> getReports({int page = 1, int pageSize = 20}) async {
    final models =
        await _dataSource.fetchReports(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dataSource = ref.watch(reportRemoteDataSourceProvider);
  return ReportRepositoryImpl(dataSource);
});
