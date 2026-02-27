import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/qc_inspection_model.dart';
import 'qc_remote_datasource.dart';

class QcRemoteDataSourceImpl implements QcRemoteDataSource {
  QcRemoteDataSourceImpl(this._client);

  // ignore: unused_field
  final DioClient _client;

  @override
  Future<List<QcInspectionModel>> fetchInspections({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final results = ['Đạt', 'Không đạt', 'Chờ'];
    return List.generate(
      5,
      (i) => QcInspectionModel(
        id: '${(page - 1) * pageSize + i + 1}',
        batchNumber: 'LÔ-${(page - 1) * pageSize + i + 1}',
        productName: 'Sản phẩm ${(page - 1) * pageSize + i + 1}',
        inspector: 'Người kiểm ${i + 1}',
        result: results[i % results.length],
        date: '2025-01-${15 + i}',
        notes: 'Ghi chú kiểm QC lô ${(page - 1) * pageSize + i + 1}',
      ),
    );
  }
}

final qcRemoteDataSourceProvider = Provider<QcRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return QcRemoteDataSourceImpl(client);
});
