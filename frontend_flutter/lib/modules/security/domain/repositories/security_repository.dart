import '../entities/security_info.dart';

/// Repository interface in domain. Implementation lives in data.
abstract class SecurityRepository {
  Future<SecurityInfo> getSecurityInfo();
}
