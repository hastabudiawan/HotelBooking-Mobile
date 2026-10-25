import 'package:intl/intl.dart';

final _apiDate = DateFormat('yyyy-MM-dd');

// DateTime(2026, 11, 10) -> "2026-11-10"
String toApiDate(DateTime date) => _apiDate.format(date);

// "2026-11-10" -> DateTime(2026, 11, 10)
DateTime parseApiDate(String value) {
  final parts = value.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

// Waktu dari backend dalam UTC. Kalau tidak ada tanda zona, anggap UTC.
DateTime parseUtc(String value) {
  final parsed = DateTime.parse(value);
  if (parsed.isUtc) return parsed;
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
  );
}
