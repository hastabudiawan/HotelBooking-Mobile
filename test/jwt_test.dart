import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/features/auth/data/jwt.dart';

String _b64(Object value) =>
    base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

String fakeJwt(Map<String, Object?> payload) =>
    '${_b64({'alg': 'HS256'})}.${_b64(payload)}.tanda-tangan';

void main() {
  test('membaca pengguna dari token dengan satu peran (teks)', () {
    final user = userFromToken(
      fakeJwt({
        'sub': 'u-1',
        'email': 'hasta@example.com',
        'name': 'Hasta Budiawan',
        'role': 'Guest',
      }),
    );

    expect(user, isNotNull);
    expect(user!.id, 'u-1');
    expect(user.fullName, 'Hasta Budiawan');
    expect(user.roles, ['Guest']);
    expect(user.initials, 'HB');
  });

  test('membaca beberapa peran (daftar)', () {
    final user = userFromToken(
      fakeJwt({
        'sub': 'u-2',
        'email': 'a@b.co',
        'name': 'Admin',
        'role': ['Admin', 'Receptionist'],
      }),
    );

    expect(user!.roles, ['Admin', 'Receptionist']);
  });

  test('nama non-ASCII terbaca dengan benar', () {
    final user = userFromToken(
      fakeJwt({'sub': '1', 'email': 'a@b.co', 'name': 'Sitî Nurhaliza'}),
    );

    expect(user!.fullName, 'Sitî Nurhaliza');
    expect(user.roles, isEmpty);
  });

  test('token rusak atau datanya kurang menghasilkan null', () {
    expect(userFromToken('bukan-token'), isNull);
    expect(userFromToken('a.b.c'), isNull);
    expect(userFromToken(fakeJwt({'sub': '1'})), isNull);
  });
}
