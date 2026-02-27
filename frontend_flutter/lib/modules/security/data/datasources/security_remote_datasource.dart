import '../models/security_info_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
/// Security.API: transaction pin, etc.
abstract class SecurityRemoteDataSource {
  Future<SecurityInfoModel> fetchSecurityInfo();
}
