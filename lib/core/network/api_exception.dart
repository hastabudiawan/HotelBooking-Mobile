// Satu jenis error untuk semua kegagalan API.
// statusCode kosong berarti server tidak terjangkau (offline, timeout, backend mati).
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;

  @override
  String toString() => message;
}

const networkErrorMessage =
    'We could not reach the server. Please try again in a moment.';

// Membaca pesan dari body error backend.
// - Validasi otomatis: { title, errors: { Field: [pesan] } } -> pesan pertama
// - ProblemDetails:    { title, detail, status }              -> detail, lalu title
String messageFromErrorBody(Object? data, int? statusCode) {
  if (data is Map) {
    final errors = data['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) return value.first.toString();
        if (value is String && value.isNotEmpty) return value;
      }
    }
    final detail = data['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    final title = data['title'];
    if (title is String && title.isNotEmpty) return title;
  }
  if (data is String && data.trim().isNotEmpty && data.length < 200) {
    return data;
  }
  return 'Request failed with status $statusCode';
}
