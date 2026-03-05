import 'package:dio/dio.dart';

/// Single Dio instance for the app. No duplicate API client per module.
class DioClient {
  DioClient({
    String? baseUrl,
    String? Function()? getToken,
    void Function()? onUnauthorized,
  }) {
    _dio = Dio(BaseOptions(baseUrl: baseUrl ?? ''));
    _dio.interceptors.addAll([
      _AuthInterceptor(getToken: getToken),
      _ErrorInterceptor(onUnauthorized: onUnauthorized),
    ]);
  }

  late final Dio _dio;
  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({String? Function()? getToken}) : _getToken = getToken;

  final String? Function()? _getToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    if (path.contains('/login') || path.contains('/register')) {
      handler.next(options);
      return;
    }
    final token = _getToken?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  _ErrorInterceptor({void Function()? onUnauthorized}) : _onUnauthorized = onUnauthorized;

  final void Function()? _onUnauthorized;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _onUnauthorized?.call();
    }
    handler.next(err);
  }
}
