import 'package:intl/intl.dart';

final _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

// 450000 -> "Rp 450.000"
String formatRupiah(num amount) => _rupiah.format(amount);

// plural(1, 'guest') -> "1 guest", plural(2, 'guest') -> "2 guests"
String plural(int count, String singular, [String? pluralForm]) {
  final word = count == 1 ? singular : (pluralForm ?? '${singular}s');
  return '$count $word';
}

final _shortDate = DateFormat('d MMM yyyy');

// DateTime(2026, 11, 10) -> "10 Nov 2026"
String formatDateShort(DateTime date) => _shortDate.format(date);

// Waktu UTC dari backend ditampilkan dalam WIB (UTC+7), sesuai jam hotel.
// DateTime.utc(2026, 11, 10, 8, 30) -> "10 Nov 2026, 15:30 WIB"
String formatDateTimeWib(DateTime utc) {
  final wib = utc.toUtc().add(const Duration(hours: 7));
  return '${DateFormat('d MMM yyyy, HH:mm').format(wib)} WIB';
}
