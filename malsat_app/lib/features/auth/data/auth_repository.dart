import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/user_model.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi _api;
  final TokenStorage _tokenStorage;
  final FlutterSecureStorage _secureStorage;

  static const _userKey = 'cached_user';

  AuthRepository({
    required AuthApi api,
    required TokenStorage tokenStorage,
    FlutterSecureStorage? secureStorage,
  })  : _api = api,
        _tokenStorage = tokenStorage,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Send OTP to phone. Returns normalized phone number.
  Future<String> login(String phone) => _api.login(phone);

  /// Verify OTP. Stores tokens and user. Returns UserModel.
  Future<UserModel> verify(String phone, String code) async {
    final data = await _api.verify(phone, code);

    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userJson);

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _cacheUser(user);

    return user;
  }

  /// Try to refresh the access token. Returns new token or null.
  Future<String?> refreshAccessToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final newAccessToken = await _api.refreshToken(refreshToken);
      await _tokenStorage.saveAccessToken(newAccessToken);
      return newAccessToken;
    } catch (_) {
      return null;
    }
  }

  /// Get the cached user if logged in.
  Future<UserModel?> getCachedUser() async {
    final hasTokens = await _tokenStorage.hasTokens();
    if (!hasTokens) return null;

    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      return UserModel.fromJson(json.decode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Clear all auth data.
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    await _secureStorage.delete(key: _userKey);
  }

  Future<void> _cacheUser(UserModel user) async {
    await _secureStorage.write(
      key: _userKey,
      value: json.encode(user.toJson()),
    );
  }
}
