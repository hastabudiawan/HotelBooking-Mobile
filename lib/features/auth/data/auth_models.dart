import '../../../core/utils/dates.dart';

// Balasan POST /api/auth/login dan /api/auth/register
class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.expiresAtUtc,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roles,
  });

  final String token;
  final DateTime expiresAtUtc;
  final String userId;
  final String fullName;
  final String email;
  final List<String> roles;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'] as String,
    expiresAtUtc: parseUtc(json['expiresAtUtc'] as String),
    userId: json['userId'].toString(),
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    roles: (json['roles'] as List).map((e) => e.toString()).toList(),
  );

  UserProfile toProfile() =>
      UserProfile(id: userId, fullName: fullName, email: email, roles: roles);
}

// Balasan GET /api/auth/me
class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roles,
  });

  final String id;
  final String fullName;
  final String email;
  final List<String> roles;

  // Huruf awal untuk avatar. Backend tidak menyimpan foto profil.
  String get initials {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty);
    final letters = words.take(2).map((w) => w[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'].toString(),
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    roles: (json['roles'] as List).map((e) => e.toString()).toList(),
  );
}
