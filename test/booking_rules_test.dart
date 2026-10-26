import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/features/bookings/data/booking_models.dart';
import 'package:paradise_view/features/bookings/domain/booking_rules.dart';

Booking _booking({
  BookingStatus status = BookingStatus.pending,
  DateTime? expiresAt,
}) => Booking(
  id: 1,
  bookingCode: 'PV-0001',
  roomId: 1,
  roomNumber: '101',
  roomTypeName: 'Standard',
  roomTypeSlug: 'standard',
  checkIn: DateTime(2026, 11, 10),
  checkOut: DateTime(2026, 11, 12),
  guestCount: 2,
  totalPrice: 900000,
  status: status,
  expiresAt: expiresAt,
  createdAt: DateTime.utc(2026, 11, 1, 8),
  nights: 2,
);

void main() {
  final now = DateTime.utc(2026, 11, 1, 8, 10);

  test('form bayar terbuka untuk Pending yang batasnya belum lewat', () {
    final booking = _booking(expiresAt: DateTime.utc(2026, 11, 1, 8, 15));
    expect(isPaymentWindowOpen(booking, now), isTrue);
  });

  test('form bayar tertutup setelah batas, termasuk tepat di batas', () {
    final expiresAt = DateTime.utc(2026, 11, 1, 8, 10);
    expect(isPaymentWindowOpen(_booking(expiresAt: expiresAt), now), isFalse);
    expect(
      isPaymentWindowOpen(
        _booking(expiresAt: DateTime.utc(2026, 11, 1, 8, 5)),
        now,
      ),
      isFalse,
    );
  });

  test('form bayar tertutup kalau bukan Pending atau tanpa batas', () {
    final future = DateTime.utc(2026, 11, 1, 9);
    expect(
      isPaymentWindowOpen(
        _booking(status: BookingStatus.confirmed, expiresAt: future),
        now,
      ),
      isFalse,
    );
    expect(isPaymentWindowOpen(_booking(), now), isFalse);
  });

  test('hanya Pending dan Confirmed yang bisa dibatalkan', () {
    for (final status in BookingStatus.values) {
      final expected =
          status == BookingStatus.pending || status == BookingStatus.confirmed;
      expect(canCancel(_booking(status: status)), expected, reason: '$status');
    }
  });

  test('hanya Confirmed yang di-refund', () {
    expect(isRefundable(_booking(status: BookingStatus.confirmed)), isTrue);
    expect(isRefundable(_booking(status: BookingStatus.pending)), isFalse);
  });

  test('formatCountdown', () {
    expect(formatCountdown(const Duration(minutes: 15)), '15:00');
    expect(formatCountdown(const Duration(minutes: 14, seconds: 32)), '14:32');
    expect(formatCountdown(const Duration(seconds: 5)), '00:05');
    expect(formatCountdown(Duration.zero), '00:00');
    expect(formatCountdown(const Duration(seconds: -3)), '00:00');
  });

  test('metode bayar cocok dengan nilai yang diterima backend', () {
    expect(PaymentMethod.transfer.apiValue, 'Transfer');
    expect(PaymentMethod.qris.apiValue, 'QRIS');
    expect(PaymentMethod.card.apiValue, 'Kartu');
    expect(PaymentMethod.card.label, 'Credit or debit card');
  });
}
