import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/qc_inspection.dart';
import '../../domain/repositories/qc_repository.dart';
import '../datasources/qc_remote_datasource.dart';
import '../datasources/qc_remote_datasource_impl.dart';

class QcRepositoryImpl implements QcRepository {
  QcRepositoryImpl(this._dataSource);

  final QcRemoteDataSource _dataSource;

  @override
  Future<List<QcInspection>> getInspections(
      {int page = 1, int pageSize = 20}) async {
    final models =
        await _dataSource.fetchInspections(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }
}

final qcRepositoryProvider = Provider<QcRepository>((ref) {
  final dataSource = ref.watch(qcRemoteDataSourceProvider);
  return QcRepositoryImpl(dataSource);
});
