import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3000/api');
const _storageKeyAccess = 'access_token';
const _storageKeyRefresh = 'refresh_token';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
  }

  Dio get dio => _dio;

  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _storageKeyAccess, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _storageKeyRefresh, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: _storageKeyAccess);

  Future<void> clearTokens() async {
    await _storage.delete(key: _storageKeyAccess);
    await _storage.delete(key: _storageKeyRefresh);
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: _storageKeyAccess);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await _storage.read(key: _storageKeyRefresh);
        if (refreshToken == null) return handler.next(err);

        final response = await _dio.post(
          '/auth/refresh',
          options: Options(headers: {'Cookie': 'refresh_token=$refreshToken'}),
        );
        final newToken = response.data['accessToken'] as String;
        await _storage.write(key: _storageKeyAccess, value: newToken);

        // Retry original request
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retried = await _dio.fetch(err.requestOptions);
        return handler.resolve(retried);
      } catch (_) {
        await _storage.deleteAll();
      }
    }
    handler.next(err);
  }
}
