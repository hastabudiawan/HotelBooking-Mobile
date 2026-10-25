import '../../../core/utils/dates.dart';

enum BookingStatus {
  pending('Awaiting payment'),
  confirmed('Confirmed'),
  checkedIn('Checked in'),
  checkedOut('Checked out'),
  expired('Expired'),
  cancelled('Cancelled'),
  noShow('No show');

  const BookingStatus(this.label);
  final String label;

  static BookingStatus fromApi(String value) => switch (value) {
    'Pending' => pending,
    'Confirmed' => confirmed,
    'CheckedIn' => checkedIn,
    'CheckedOut' => checkedOut,
    'Expired' => expired,
    'Cancelled' => cancelled,
    'NoShow' => noShow,
    _ => throw FormatException('Status booking tidak dikenal: $value'),
  };
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded;

  static PaymentStatus fromApi(String value) => switch (value) {
    'Pending' => pending,
    'Paid' => paid,
    'Failed' => failed,
    'Refunded' => refunded,
    _ => throw FormatException('Status pembayaran tidak dikenal: $value'),
  };
}

// Nilai apiValue persis seperti yang diterima backend.
enum PaymentMethod {
  transfer('Transfer'),
  qris('QRIS'),
  card('Kartu');

  const PaymentMethod(this.apiValue);
  final String apiValue;
}

class Booking {
  const Booking({
    required this.id,
    required this.bookingCode,
    required this.roomId,
    required this.roomNumber,
    required this.roomTypeName,
    required this.roomTypeSlug,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.nights,
    this.expiresAt,
  });

  final int id;
  final String bookingCode;
  final int roomId;
  final String roomNumber;
  final String roomTypeName;
  final String roomTypeSlug;
  final DateTime checkIn; // tanggal saja
  final DateTime checkOut; // tanggal saja
  final int guestCount;
  final int totalPrice;
  final BookingStatus status;
  final DateTime? expiresAt; // UTC, batas bayar saat status pending
  final DateTime createdAt; // UTC
  final int nights;

  factory Booking.fromJson(Map<String, dynamic> json) {
    final expiresAt = json['expiresAt'] as String?;
    return Booking(
      id: json['id'] as int,
      bookingCode: json['bookingCode'] as String,
      roomId: json['roomId'] as int,
      roomNumber: json['roomNumber'].toString(),
      roomTypeName: json['roomTypeName'] as String,
      roomTypeSlug: json['roomTypeSlug'] as String,
      checkIn: parseApiDate(json['checkIn'] as String),
      checkOut: parseApiDate(json['checkOut'] as String),
      guestCount: json['guestCount'] as int,
      totalPrice: (json['totalPrice'] as num).round(),
      status: BookingStatus.fromApi(json['status'] as String),
      expiresAt: expiresAt == null ? null : parseUtc(expiresAt),
      createdAt: parseUtc(json['createdAt'] as String),
      nights: json['nights'] as int,
    );
  }
}

class Payment {
  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    this.paidAt,
  });

  final int id;
  final int bookingId;
  final int amount;
  final String method;
  final PaymentStatus status;
  final DateTime? paidAt; // UTC

  factory Payment.fromJson(Map<String, dynamic> json) {
    final paidAt = json['paidAt'] as String?;
    return Payment(
      id: json['id'] as int,
      bookingId: json['bookingId'] as int,
      amount: (json['amount'] as num).round(),
      method: json['method'].toString(),
      status: PaymentStatus.fromApi(json['status'] as String),
      paidAt: paidAt == null ? null : parseUtc(paidAt),
    );
  }
}

// Balasan POST /api/bookings/{id}/pay
class PaymentResult {
  const PaymentResult({required this.payment, required this.booking});

  final Payment payment;
  final Booking booking;

  factory PaymentResult.fromJson(Map<String, dynamic> json) => PaymentResult(
    payment: Payment.fromJson(json['payment'] as Map<String, dynamic>),
    booking: Booking.fromJson(json['booking'] as Map<String, dynamic>),
  );
}
