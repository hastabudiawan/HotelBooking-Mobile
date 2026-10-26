import 'dart:convert';

import 'auth_models.dart';

// Membaca isi (payload) token. Tidak memeriksa tanda tangan.
Map<String, dynamic>? decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final decoded = jsonDecode(json);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

// Klaim dari backend: sub (id), email, name, dan role (teks kalau satu peran,
// daftar kalau beberapa). Null kalau token rusak atau datanya kurang.
UserProfile? userFromToken(String token) {
  final payload = decodeJwtPayload(token);
  if (payload == null) return null;

  final id = payload['sub']?.toString();
  final email = payload['email']?.toString();
  final name = payload['name']?.toString();
  if (id == null || email == null || name == null) return null;

  final role = payload['role'];
  final roles = switch (role) {
    final List<dynamic> list => list.map((e) => e.toString()).toList(),
    final String single => [single],
    _ => <String>[],
  };

  return UserProfile(id: id, fullName: name, email: email, roles: roles);
}
