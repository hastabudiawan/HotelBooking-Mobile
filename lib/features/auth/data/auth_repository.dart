import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final auth = await _api.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
      parse: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
    await _tokens.save(auth.token, auth.expiresAtUtc);
    return auth;
  }

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final auth = await _api.post(
      '/api/auth/register',
      body: {'fullName': fullName, 'email': email, 'password': password},
      parse: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
    await _tokens.save(auth.token, auth.expiresAtUtc);
    return auth;
  }

  Future<UserProfile> me() {
    return _api.get(
      '/api/auth/me',
      parse: (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<bool> hasValidToken() async => await _tokens.readValid() != null;

  Future<void> logout() => _tokens.clear();
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  ),
);
