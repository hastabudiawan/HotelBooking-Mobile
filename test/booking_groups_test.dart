import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/core/utils/format.dart';
import 'package:paradise_view/features/bookings/data/booking_models.dart';
import 'package:paradise_view/features/bookings/domain/booking_rules.dart';

Booking _booking(
  int id, {
  BookingStatus status = BookingStatus.confirmed,
  DateTime? checkIn,
  DateTime? expiresAt,
}) => Booking(
  id: id,
  bookingCode: 'PV-$id',
  roomId: 1,
  roomNumber: '101',
  roomTypeName: 'Standard',
  roomTypeSlug: 'standard',
  checkIn: checkIn ?? DateTime(2026, 11, 10),
  checkOut: (checkIn ?? DateTime(2026, 11, 10)).add(const Duration(days: 2)),
  guestCount: 2,
  totalPrice: 900000,
  status: status,
  expiresAt: expiresAt,
  createdAt: DateTime.utc(2026, 11, 1, 8),
  nights: 2,
);

void main() {
  final now = DateTime.utc(2026, 11, 1, 8, 10);

  test('effectiveStatus: Pending yang lewat batas dianggap Expired', () {
    final overdue = _booking(
      1,
      status: BookingStatus.pending,
      expiresAt: DateTime.utc(2026, 11, 1, 8, 5),
    );
    final open = _booking(
      2,
      status: BookingStatus.pending,
      expiresAt: DateTime.utc(2026, 11, 1, 8, 15),
    );

    expect(effectiveStatus(overdue, now), BookingStatus.expired);
    expect(effectiveStatus(open, now), BookingStatus.pending);
    expect(
      effectiveStatus(_booking(3, status: BookingStatus.confirmed), now),
      BookingStatus.confirmed,
    );
  });

  test('groupOf mengelompokkan semua status', () {
    BookingGroup group(BookingStatus status) =>
        groupOf(_booking(1, status: status), now);

    expect(group(BookingStatus.confirmed), BookingGroup.active);
    expect(group(BookingStatus.checkedIn), BookingGroup.active);
    expect(group(BookingStatus.checkedOut), BookingGroup.completed);
    expect(group(BookingStatus.noShow), BookingGroup.completed);
    expect(group(BookingStatus.cancelled), BookingGroup.closed);
    expect(group(BookingStatus.expired), BookingGroup.closed);
  });

  test('activeBookings menyaring dan mengurutkan dari check-in terdekat', () {
    final list = [
      _booking(1, checkIn: DateTime(2026, 12, 5)),
      _booking(2, status: BookingStatus.cancelled),
      _booking(3, checkIn: DateTime(2026, 11, 20)),
      _booking(4, status: BookingStatus.checkedOut),
    ];

    expect(activeBookings(list, now).map((b) => b.id), [3, 1]);
  });

  test(
    'pastBookings memuat selain Active dan mengurutkan dari yang terbaru',
    () {
      final list = [
        _booking(
          1,
          status: BookingStatus.checkedOut,
          checkIn: DateTime(2026, 9, 1),
        ),
        _booking(
          2,
          status: BookingStatus.cancelled,
          checkIn: DateTime(2026, 10, 1),
        ),
        _booking(3, checkIn: DateTime(2026, 12, 5)), // Confirmed: bukan Past
        _booking(
          4,
          status: BookingStatus.pending,
          checkIn: DateTime(2026, 11, 3),
          expiresAt: DateTime.utc(2026, 11, 1, 8, 0), // lewat batas: Past
        ),
      ];

      expect(pastBookings(list, now).map((b) => b.id), [4, 2, 1]);
    },
  );

  test('formatDateRange tanpa tahun untuk tahun berjalan', () {
    expect(
      formatDateRange(
        DateTime(2026, 3, 27),
        DateTime(2026, 3, 29),
        currentYear: 2026,
      ),
      '27 Mar to 29 Mar',
    );
  });

  test('formatDateRange menambah tahun kalau bukan tahun berjalan', () {
    expect(
      formatDateRange(
        DateTime(2027, 3, 27),
        DateTime(2027, 3, 29),
        currentYear: 2026,
      ),
      '27 Mar to 29 Mar 2027',
    );
    expect(
      formatDateRange(
        DateTime(2026, 12, 30),
        DateTime(2027, 1, 2),
        currentYear: 2026,
      ),
      '30 Dec 2026 to 2 Jan 2027',
    );
  });
}
