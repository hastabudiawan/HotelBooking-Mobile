import 'package:intl/intl.dart';

final _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

// 450000 -> "Rp 450.000"
String formatRupiah(num amount) => _rupiah.format(amount);
