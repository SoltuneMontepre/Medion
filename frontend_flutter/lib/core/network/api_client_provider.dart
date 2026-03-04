import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import 'dio_client.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:9999',
);

final apiClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    baseUrl: _baseUrl,
    getToken: () => ref.read(authProvider).token,
  );
});
