import '../models/qc_inspection_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
abstract class QcRemoteDataSource {
  Future<List<QcInspectionModel>> fetchInspections(
      {int page = 1, int pageSize = 20});
}
