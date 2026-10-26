// Alamat tujuan setelah login berasal dari URL, jadi harus dicek. Hanya alamat
// di dalam aplikasi yang diterima. Tanpa ini, tautan berbahaya bisa
// mengarahkan pengguna ke tempat lain setelah masuk.
String safeNext(String? next) {
  if (next == null || next.isEmpty) return '/home';
  if (!next.startsWith('/') ||
      next.startsWith('//') ||
      next.startsWith('/\\')) {
    return '/home';
  }
  const blocked = ['/login', '/register', '/splash'];
  final path = Uri.tryParse(next)?.path ?? '';
  if (blocked.contains(path)) return '/home';
  return next;
}

// Halaman yang butuh login: tab Booking dan Account beserta turunannya.
bool requiresLogin(String path) {
  const protectedRoots = ['/bookings', '/account', '/book'];
  return protectedRoots.any(
    (root) => path == root || path.startsWith('$root/'),
  );
}

// /login atau /register, dengan ?next= kalau ada.
String authLocation(String path, {String? next}) {
  return Uri(
    path: path,
    queryParameters: next == null ? null : {'next': next},
  ).toString();
}

// Mengembalikan alamat pengalihan, atau null kalau tidak perlu dialihkan.
String? authRedirect({required bool loggedIn, required Uri uri}) {
  final path = uri.path;

  if (!loggedIn && requiresLogin(path)) {
    return authLocation('/login', next: uri.toString());
  }

  final isAuthPage = path == '/login' || path == '/register';
  if (loggedIn && isAuthPage) {
    return safeNext(uri.queryParameters['next']);
  }

  return null;
}
