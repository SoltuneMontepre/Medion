import '../models/security_info_model.dart';

/// DataSource talks to API. Uses Dio from core/network via injector.
/// Security.API: transaction pin (GET/POST/PUT /api/v1/pin), /me for user.
abstract class SecurityRemoteDataSource {
  Future<SecurityInfoModel> fetchSecurityInfo();

  /// POST /api/v1/pin — set PIN for the first time (pin: 4 digits).
  Future<void> setPin(String pin);

  /// PUT /api/v1/pin — change PIN (oldPin, newPin: 4 digits).
  Future<void> changePin(String oldPin, String newPin);
}
