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

enum BookingGroup { active, completed, closed }

// Status yang ditampilkan ke tamu: Pending yang batas bayarnya sudah lewat
// dianggap Expired, walau job di backend belum sempat mengubahnya.
BookingStatus effectiveStatus(Booking booking, DateTime nowUtc) {
  final expiresAt = booking.expiresAt;
  if (booking.status == BookingStatus.pending &&
      expiresAt != null &&
      !expiresAt.isAfter(nowUtc)) {
    return BookingStatus.expired;
  }
  return booking.status;
}

BookingGroup groupOf(Booking booking, DateTime nowUtc) {
  return switch (effectiveStatus(booking, nowUtc)) {
    BookingStatus.pending ||
    BookingStatus.confirmed ||
    BookingStatus.checkedIn => BookingGroup.active,
    BookingStatus.checkedOut || BookingStatus.noShow => BookingGroup.completed,
    BookingStatus.cancelled || BookingStatus.expired => BookingGroup.closed,
  };
}

// Tab Active: check-in terdekat di atas.
List<Booking> activeBookings(List<Booking> all, DateTime nowUtc) {
  final result = all
      .where((b) => groupOf(b, nowUtc) == BookingGroup.active)
      .toList();
  result.sort((a, b) => a.checkIn.compareTo(b.checkIn));
  return result;
}

// Tab Past: yang terbaru di atas.
List<Booking> pastBookings(List<Booking> all, DateTime nowUtc) {
  final result = all
      .where((b) => groupOf(b, nowUtc) != BookingGroup.active)
      .toList();
  result.sort((a, b) {
    final byDate = b.checkIn.compareTo(a.checkIn);
    return byDate != 0 ? byDate : b.id.compareTo(a.id);
  });
  return result;
}
