import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/features/auth/presentation/auth_validators.dart';

void main() {
  test('validateEmail', () {
    expect(validateEmail(''), isNotNull);
    expect(validateEmail('tanpa-at'), isNotNull);
    expect(validateEmail('a@b'), isNotNull);
    expect(validateEmail('hasta@example.com'), isNull);
    expect(validateEmail('  hasta@example.com  '), isNull);
    expect(isValidEmail('hasta@example.com'), isTrue);
    expect(isValidEmail('x'), isFalse);
  });

  test('validateNewPassword mengikuti aturan backend', () {
    expect(
      validateNewPassword('Ab1'),
      'Password must be at least 8 characters.',
    );
    expect(
      validateNewPassword('ABCDEFG1'),
      'Password must contain a lowercase letter.',
    );
    expect(
      validateNewPassword('abcdefg1'),
      'Password must contain an uppercase letter.',
    );
    expect(validateNewPassword('Abcdefgh'), 'Password must contain a number.');
    expect(validateNewPassword('Abcdefg1'), isNull);
  });

  test('validatePasswordPresent dan validateFullName', () {
    expect(validatePasswordPresent(''), isNotNull);
    expect(validatePasswordPresent('apa saja'), isNull);
    expect(validateFullName('   '), isNotNull);
    expect(validateFullName('Hasta'), isNull);
  });
}
