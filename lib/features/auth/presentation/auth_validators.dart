final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

String? validateEmail(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'Enter your email address.';
  if (!isValidEmail(text)) return 'Enter a valid email address.';
  return null;
}

String? validateFullName(String? value) {
  if ((value ?? '').trim().isEmpty) return 'Enter your full name.';
  return null;
}

// Untuk Sign in: cukup tidak kosong. Aturan kekuatan hanya berlaku saat mendaftar.
String? validatePasswordPresent(String? value) {
  if ((value ?? '').isEmpty) return 'Enter your password.';
  return null;
}

// Untuk Sign up: sama dengan aturan backend.
String? validateNewPassword(String? value) {
  final password = value ?? '';
  if (password.length < 8) return 'Password must be at least 8 characters.';
  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return 'Password must contain a lowercase letter.';
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'Password must contain an uppercase letter.';
  }
  if (!RegExp(r'\d').hasMatch(password)) {
    return 'Password must contain a number.';
  }
  return null;
}
