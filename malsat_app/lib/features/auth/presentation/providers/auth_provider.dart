import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/auth_api.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_state.dart';
import '../../domain/user_model.dart';

// Core singletons
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// Dio without auth interceptor — used by auth API itself (no cycle).
final _baseDioProvider = Provider<Dio>((ref) => createDio());

/// Auth API uses the base Dio (no interceptor needed for login/verify/refresh).
final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(_baseDioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.read(authApiProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

// Auth state notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Dio WITH auth interceptor — used by all non-auth API calls.
/// The interceptor attaches the Bearer token and handles 401 refresh.
final dioProvider = Provider<Dio>((ref) {
  final dio = createDio();
  final tokenStorage = ref.read(tokenStorageProvider);

  dio.interceptors.insert(
    0,
    AuthInterceptor(
      dio: dio,
      tokenStorage: tokenStorage,
      onAuthExpired: () => ref.read(authProvider.notifier).logout(),
    ),
  );

  return dio;
});

// Convenience provider: is the user currently authenticated?
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is Authenticated;
});

// Convenience provider: current user or null
final currentUserProvider = Provider<UserModel?>((ref) {
  final state = ref.watch(authProvider);
  if (state is Authenticated) return state.user;
  return null;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthInitial()) {
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    final user = await _repository.getCachedUser();
    if (user != null) {
      state = Authenticated(user);
    } else {
      state = const Unauthenticated();
    }
  }

  Future<String> sendOtp(String phone) async {
    return _repository.login(phone);
  }

  Future<void> verifyOtp(String phone, String code) async {
    state = const AuthLoading();
    try {
      final user = await _repository.verify(phone, code);
      state = Authenticated(user);
    } catch (e) {
      state = AuthError(e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const Unauthenticated();
  }
}
