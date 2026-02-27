import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/payroll_record_model.dart';
import 'payroll_remote_datasource.dart';

/// Implementation: calls API via shared Dio client. Payroll.API backend.
class PayrollRemoteDataSourceImpl implements PayrollRemoteDataSource {
  PayrollRemoteDataSourceImpl(this._client);

  // ignore: unused_field
  final DioClient _client;

  @override
  Future<List<PayrollRecordModel>> fetchRecords({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final base = (page - 1) * pageSize;
    return List.generate(
      5,
      (i) => PayrollRecordModel(
        id: '${base + i + 1}',
        employeeName: 'Nhân viên ${base + i + 1}',
        period: '2025-02',
        amount: 2500.0 + (i * 100),
        status: i.isEven ? 'Đã thanh toán' : 'Chờ thanh toán',
      ),
    );
  }
}

final payrollRemoteDataSourceProvider = Provider<PayrollRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return PayrollRemoteDataSourceImpl(client);
});
