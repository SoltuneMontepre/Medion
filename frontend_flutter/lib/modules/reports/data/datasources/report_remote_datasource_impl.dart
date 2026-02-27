import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/report_model.dart';
import 'report_remote_datasource.dart';

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  ReportRemoteDataSourceImpl(this._client);

  // ignore: unused_field
  final DioClient _client;

  @override
  Future<List<ReportModel>> fetchReports({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final types = ['Hàng ngày', 'Hàng tuần', 'Hàng tháng'];
    final statuses = ['Đã tạo', 'Chờ tạo', 'Đã tạo'];
    return List.generate(
      5,
      (i) => ReportModel(
        id: '${(page - 1) * pageSize + i + 1}',
        title: 'Báo cáo sản xuất ${types[i % types.length]} ${(page - 1) * pageSize + i + 1}',
        type: types[i % types.length],
        status: statuses[i % statuses.length],
        date: '2025-01-${15 + i}',
        createdBy: 'Hệ thống',
      ),
    );
  }
}

final reportRemoteDataSourceProvider =
    Provider<ReportRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReportRemoteDataSourceImpl(client);
});
