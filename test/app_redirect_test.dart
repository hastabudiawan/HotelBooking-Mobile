import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/core/router/app_redirect.dart';

void main() {
  group('authRedirect', () {
    test('belum login membuka tab yang butuh login diarahkan ke Sign in', () {
      expect(
        authRedirect(loggedIn: false, uri: Uri.parse('/bookings')),
        '/login?next=%2Fbookings',
      );
      expect(
        authRedirect(loggedIn: false, uri: Uri.parse('/account')),
        '/login?next=%2Faccount',
      );
      expect(
        authRedirect(loggedIn: false, uri: Uri.parse('/bookings/12')),
        '/login?next=%2Fbookings%2F12',
      );
    });

    test('halaman publik tidak dialihkan', () {
      for (final path in [
        '/home',
        '/rooms',
        '/login',
        '/register',
        '/splash',
      ]) {
        expect(authRedirect(loggedIn: false, uri: Uri.parse(path)), isNull);
      }
    });

    test('sudah login membuka /login diarahkan ke tujuan', () {
      expect(
        authRedirect(loggedIn: true, uri: Uri.parse('/login?next=%2Faccount')),
        '/account',
      );
      expect(authRedirect(loggedIn: true, uri: Uri.parse('/login')), '/home');
      expect(
        authRedirect(loggedIn: true, uri: Uri.parse('/register')),
        '/home',
      );
    });

    test('sudah login membuka tab yang butuh login tidak dialihkan', () {
      expect(authRedirect(loggedIn: true, uri: Uri.parse('/bookings')), isNull);
    });

    test('halaman booking sebuah kamar butuh login', () {
      expect(
        authRedirect(loggedIn: false, uri: Uri.parse('/book/deluxe')),
        '/login?next=%2Fbook%2Fdeluxe',
      );
      expect(
        authRedirect(loggedIn: true, uri: Uri.parse('/book/deluxe')),
        isNull,
      );
    });
  });

  group('safeNext', () {
    test('menerima alamat di dalam aplikasi', () {
      expect(safeNext('/bookings'), '/bookings');
      expect(safeNext('/rooms/deluxe?x=1'), '/rooms/deluxe?x=1');
    });

    test('menolak alamat luar atau berbahaya', () {
      expect(safeNext(null), '/home');
      expect(safeNext(''), '/home');
      expect(safeNext('//situs-lain.com'), '/home');
      expect(safeNext('https://situs-lain.com'), '/home');
      expect(safeNext('/\\situs-lain.com'), '/home');
      expect(safeNext('javascript:alert(1)'), '/home');
    });

    test('tidak kembali ke halaman login atau splash', () {
      expect(safeNext('/login'), '/home');
      expect(safeNext('/register?next=/bookings'), '/home');
      expect(safeNext('/splash'), '/home');
    });
  });
}
