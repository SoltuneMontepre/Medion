import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/security_info_model.dart';
import 'security_remote_datasource.dart';

const _pinPath = '/api/v1/pin';
const _mePath = '/api/v1/me';

/// Implementation: calls API via shared Dio client. GET /me + GET /pin for info; POST/PUT /pin for set/change.
class SecurityRemoteDataSourceImpl implements SecurityRemoteDataSource {
  SecurityRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<SecurityInfoModel> fetchSecurityInfo() async {
    final meFuture = _client.dio.get<Map<String, dynamic>>(_mePath);
    final pinFuture = _client.dio.get<Map<String, dynamic>>(_pinPath);

    final meResponse = await meFuture;
    final pinResponse = await pinFuture;

    final meData = _extractData(meResponse.data);
    final pinData = _extractData(pinResponse.data);

    final userId = meData != null ? (meData['id'] as String? ?? '') : '';
    final hasPin = pinData != null ? (pinData['hasPin'] as bool? ?? false) : false;

    return SecurityInfoModel(
      userId: userId,
      transactionPinSet: hasPin,
      lastLogin: '—',
    );
  }

  static Map<String, dynamic>? _extractData(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final data = json['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  @override
  Future<void> setPin(String pin) async {
    await _client.dio.post<Map<String, dynamic>>(
      _pinPath,
      data: <String, dynamic>{'pin': pin},
    );
  }

  @override
  Future<void> changePin(String oldPin, String newPin) async {
    await _client.dio.put<Map<String, dynamic>>(
      _pinPath,
      data: <String, dynamic>{
        'oldPin': oldPin,
        'newPin': newPin,
      },
    );
  }
}

final securityRemoteDataSourceProvider = Provider<SecurityRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return SecurityRemoteDataSourceImpl(client);
});
