import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_models.dart';
import '../data/auth_repository.dart';

// Pengguna yang sudah login saat aplikasi dibuka. Diisi di main() dari token
// yang tersimpan, supaya router tahu status login sejak frame pertama.
final initialUserProvider = Provider<UserProfile?>((ref) => null);

class AuthController extends Notifier<UserProfile?> {
  @override
  UserProfile? build() => ref.read(initialUserProvider);

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  // Error dari backend dilempar sebagai ApiException ke pemanggil (halaman form).
  Future<void> login({required String email, required String password}) async {
    final auth = await _repository.login(email: email, password: password);
    state = auth.toProfile();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final auth = await _repository.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    state = auth.toProfile();
  }

  Future<void> logout() async {
    await _repository.logout();
    state = null;
  }

  // Dipanggil klien API saat backend menjawab 401. Tokennya sudah dibuang.
  void sessionExpired() {
    if (state != null) state = null;
  }
}

final authControllerProvider = NotifierProvider<AuthController, UserProfile?>(
  AuthController.new,
);
