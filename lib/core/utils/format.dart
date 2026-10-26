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
