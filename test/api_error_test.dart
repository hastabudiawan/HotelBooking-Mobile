import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/core/network/api_exception.dart';

void main() {
  test('pesan validasi dari errors diambil lebih dulu', () {
    final message = messageFromErrorBody({
      'title': 'One or more validation errors occurred.',
      'errors': {
        'Password': ['Password minimal 8 karakter.'],
      },
    }, 400);

    expect(message, 'Password minimal 8 karakter.');
  });

  test('ProblemDetails memakai detail, lalu title', () {
    expect(
      messageFromErrorBody({
        'title': 'Unauthorized',
        'detail': 'Email atau password salah.',
      }, 401),
      'Email atau password salah.',
    );
    expect(messageFromErrorBody({'title': 'Not Found'}, 404), 'Not Found');
  });

  test('body kosong memakai pesan bawaan dengan status', () {
    expect(messageFromErrorBody(null, 500), 'Request failed with status 500');
  });

  test('ApiException menandai jenis error dari status', () {
    expect(const ApiException('x', statusCode: 401).isUnauthorized, isTrue);
    expect(const ApiException('x', statusCode: 404).isNotFound, isTrue);
    expect(const ApiException('x', statusCode: 409).isConflict, isTrue);
    expect(const ApiException('x').isNetworkError, isTrue);
  });
}
