import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/security_info_model.dart';
import 'security_remote_datasource.dart';

/// Implementation: calls API via shared Dio client. Security.API backend.
class SecurityRemoteDataSourceImpl implements SecurityRemoteDataSource {
  SecurityRemoteDataSourceImpl(this._client);

  // ignore: unused_field
  final DioClient _client;

  @override
  Future<SecurityInfoModel> fetchSecurityInfo() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const SecurityInfoModel(
      userId: 'current-user',
      transactionPinSet: false,
      lastLogin: '2025-02-26T08:00:00Z',
    );
  }
}

final securityRemoteDataSourceProvider = Provider<SecurityRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return SecurityRemoteDataSourceImpl(client);
});
