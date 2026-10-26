import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/core/network/api_exception.dart';
import 'package:paradise_view/features/auth/application/auth_controller.dart';
import 'package:paradise_view/features/auth/data/auth_models.dart';
import 'package:paradise_view/features/auth/data/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  AuthResponse _response(String email, String name) => AuthResponse(
    token: 'x.y.z',
    expiresAtUtc: DateTime.utc(2099),
    userId: 'u-1',
    fullName: name,
    email: email,
    roles: const ['Guest'],
  );

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    if (password == 'salah') {
      throw const ApiException('Email atau password salah.', statusCode: 401);
    }
    return _response(email, 'Hasta Budiawan');
  }

  @override
  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async => _response(email, fullName);

  @override
  Future<UserProfile> me() => throw UnimplementedError();

  @override
  Future<bool> hasValidToken() async => true;

  @override
  Future<void> logout() async {}
}

void main() {
  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('awalnya belum login', () {
    expect(makeContainer().read(authControllerProvider), isNull);
  });

  test('login berhasil mengisi pengguna, logout mengosongkannya', () async {
    final container = makeContainer();
    final controller = container.read(authControllerProvider.notifier);

    await controller.login(email: 'a@b.co', password: 'Benar123');
    expect(container.read(authControllerProvider)?.email, 'a@b.co');

    await controller.logout();
    expect(container.read(authControllerProvider), isNull);
  });

  test('login gagal melempar ApiException dan status tetap kosong', () async {
    final container = makeContainer();
    final controller = container.read(authControllerProvider.notifier);

    await expectLater(
      controller.login(email: 'a@b.co', password: 'salah'),
      throwsA(isA<ApiException>()),
    );
    expect(container.read(authControllerProvider), isNull);
  });

  test('register langsung membuat pengguna login', () async {
    final container = makeContainer();
    await container
        .read(authControllerProvider.notifier)
        .register(
          fullName: 'Siti Aminah',
          email: 's@b.co',
          password: 'Benar123',
        );

    expect(container.read(authControllerProvider)?.fullName, 'Siti Aminah');
  });

  test('sessionExpired mengeluarkan pengguna', () async {
    final container = makeContainer();
    final controller = container.read(authControllerProvider.notifier);
    await controller.login(email: 'a@b.co', password: 'Benar123');

    controller.sessionExpired();
    expect(container.read(authControllerProvider), isNull);
  });
}
