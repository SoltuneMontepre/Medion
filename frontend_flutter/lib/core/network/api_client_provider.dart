import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import 'dio_client.dart';

// Use 127.0.0.1 so Windows desktop uses IPv4 (localhost can resolve to IPv6 and fail on Windows).
const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:9999',
);

final apiClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    baseUrl: _baseUrl,
    getToken: () => ref.read(authProvider).token,
  );
});
