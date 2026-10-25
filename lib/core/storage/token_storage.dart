import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Token JWT disimpan di Keychain (iOS) atau Keystore (Android), bukan di
// SharedPreferences, karena token adalah kredensial.
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _expiryKey = 'auth_token_expires_at';

  Future<void> save(String token, DateTime expiresAtUtc) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(
      key: _expiryKey,
      value: expiresAtUtc.toUtc().toIso8601String(),
    );
  }

  // Mengembalikan token hanya kalau masih berlaku. Token kedaluwarsa dihapus
  // dan dianggap tidak ada, sama seperti cookie yang berakhir di web.
  Future<String?> readValid() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return null;

    final raw = await _storage.read(key: _expiryKey);
    final expiresAt = raw == null ? null : DateTime.tryParse(raw);
    if (expiresAt == null || !expiresAt.isAfter(DateTime.now().toUtc())) {
      await clear();
      return null;
    }
    return token;
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiryKey);
  }
}
