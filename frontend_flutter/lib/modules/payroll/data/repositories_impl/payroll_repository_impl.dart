import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/payroll_record.dart';
import '../../domain/repositories/payroll_repository.dart';
import '../datasources/payroll_remote_datasource.dart';
import '../datasources/payroll_remote_datasource_impl.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  PayrollRepositoryImpl(this._dataSource);

  final PayrollRemoteDataSource _dataSource;

  @override
  Future<List<PayrollRecord>> getRecords({int page = 1, int pageSize = 20}) async {
    final models = await _dataSource.fetchRecords(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }
}

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  final dataSource = ref.watch(payrollRemoteDataSourceProvider);
  return PayrollRepositoryImpl(dataSource);
});
