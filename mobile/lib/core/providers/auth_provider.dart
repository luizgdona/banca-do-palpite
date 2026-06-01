import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({required this.status, this.user, this.error});

  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.authenticated(UserModel user) : this(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated([String? error])
      : this(status: AuthStatus.unauthenticated, error: error);
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  late ApiClient _client;

  @override
  Future<AuthState> build() async {
    _client = ref.read(apiClientProvider);
    return _tryRestoreSession();
  }

  Future<AuthState> _tryRestoreSession() async {
    final token = await _client.getAccessToken();
    if (token == null) return const AuthState.unauthenticated();

    try {
      final response = await _client.dio.get('/users/me');
      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      return AuthState.authenticated(user);
    } catch (_) {
      return const AuthState.unauthenticated();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      await _client.saveTokens(accessToken: response.data['accessToken'] as String);
      final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      state = AsyncValue.data(AuthState.authenticated(user));
    } on DioException catch (e) {
      final message = _extractError(e);
      state = AsyncValue.data(AuthState.unauthenticated(message));
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final response = await _client.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      await _client.saveTokens(accessToken: response.data['accessToken'] as String);
      final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
      state = AsyncValue.data(AuthState.authenticated(user));
    } on DioException catch (e) {
      final message = _extractError(e);
      state = AsyncValue.data(AuthState.unauthenticated(message));
    }
  }

  Future<void> logout() async {
    try {
      await _client.dio.post('/auth/logout');
    } catch (_) {}
    await _client.clearTokens();
    state = const AsyncValue.data(AuthState.unauthenticated());
  }

  String _extractError(DioException e) {
    try {
      return (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
          'Ocorreu um erro. Tente novamente.';
    } catch (_) {
      return 'Ocorreu um erro. Tente novamente.';
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
