import 'package:dio/dio.dart';

/// Single Dio instance for the app. No duplicate API client per module.
class DioClient {
  DioClient({String? baseUrl}) {
    _dio = Dio(BaseOptions(baseUrl: baseUrl ?? ''));
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  late final Dio _dio;
  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: attach auth token from core/auth when implemented
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Map API errors to app-level exceptions if needed
    handler.next(err);
  }
}
