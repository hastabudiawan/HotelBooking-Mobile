import '../../../core/utils/dates.dart';

const maxNights = 30;

// Mengembalikan pesan error, atau null kalau rentang tanggal valid.
String? validateStay(DateTime checkIn, DateTime checkOut, DateTime today) {
  if (checkIn.isBefore(today)) return 'Check-in cannot be before today.';
  if (!checkOut.isAfter(checkIn)) {
    return 'Check-out must be after check-in.';
  }
  if (nightsBetween(checkIn, checkOut) > maxNights) {
    return 'You can stay for up to $maxNights nights.';
  }
  return null;
}
