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

// Hotel berada di WIB (UTC+7). Offset tetap, seperti di backend.
const hotelUtcOffset = Duration(hours: 7);

// "Hari ini" menurut jam hotel, sebagai tanggal tanpa jam.
// Parameter now hanya untuk tes.
DateTime hotelToday({DateTime? now}) {
  final hotelNow = (now ?? DateTime.now()).toUtc().add(hotelUtcOffset);
  return DateTime(hotelNow.year, hotelNow.month, hotelNow.day);
}

// Menambah hari pada tanggal. Aman melewati pergantian bulan dan tahun.
DateTime addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

// Jumlah malam antara dua tanggal. Dihitung lewat UTC supaya tidak terpengaruh
// pergantian jam musim panas di zona waktu perangkat.
int nightsBetween(DateTime checkIn, DateTime checkOut) {
  final start = DateTime.utc(checkIn.year, checkIn.month, checkIn.day);
  final end = DateTime.utc(checkOut.year, checkOut.month, checkOut.day);
  return end.difference(start).inDays;
}
