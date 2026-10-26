import '../data/booking_models.dart';

// Form bayar hanya muncul untuk booking Pending yang batas bayarnya belum lewat.
bool isPaymentWindowOpen(Booking booking, DateTime nowUtc) {
  final expiresAt = booking.expiresAt;
  return booking.status == BookingStatus.pending &&
      expiresAt != null &&
      expiresAt.isAfter(nowUtc);
}

bool canCancel(Booking booking) =>
    booking.status == BookingStatus.pending ||
    booking.status == BookingStatus.confirmed;

// Booking yang sudah dibayar (Confirmed) di-refund penuh saat dibatalkan.
bool isRefundable(Booking booking) => booking.status == BookingStatus.confirmed;

// Duration(minutes: 14, seconds: 32) -> "14:32". Nilai negatif ditampilkan "00:00".
String formatCountdown(Duration remaining) {
  final seconds = remaining.isNegative ? 0 : remaining.inSeconds;
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}
