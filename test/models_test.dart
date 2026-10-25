import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/core/utils/dates.dart';
import 'package:paradise_view/features/auth/data/auth_models.dart';
import 'package:paradise_view/features/bookings/data/booking_models.dart';
import 'package:paradise_view/features/rooms/data/room_models.dart';

void main() {
  test('RoomType membaca harga desimal sebagai bilangan bulat', () {
    final room = RoomType.fromJson({
      'id': 1,
      'name': 'Deluxe',
      'slug': 'deluxe',
      'description': 'Kamar luas',
      'basePrice': 450000.0,
      'capacity': 2,
      'imageUrl': null,
    });

    expect(room.basePrice, 450000);
    expect(room.imageUrl, isNull);
  });

  test('Booking membaca tanggal, status, dan batas bayar UTC', () {
    final booking = Booking.fromJson({
      'id': 7,
      'bookingCode': 'PV-0007',
      'roomId': 3,
      'roomNumber': '201',
      'roomTypeName': 'Deluxe',
      'roomTypeSlug': 'deluxe',
      'checkIn': '2026-11-10',
      'checkOut': '2026-11-12',
      'guestCount': 2,
      'totalPrice': 900000,
      'status': 'Pending',
      'expiresAt': '2026-11-01T08:30:00Z',
      'createdAt': '2026-11-01T08:15:00Z',
      'nights': 2,
    });

    expect(booking.checkIn, DateTime(2026, 11, 10));
    expect(booking.status, BookingStatus.pending);
    expect(booking.expiresAt!.isUtc, isTrue);
    expect(booking.expiresAt!.minute, 30);
  });

  test('Booking tanpa batas bayar dan status tidak dikenal', () {
    final json = {
      'id': 1,
      'bookingCode': 'PV-0001',
      'roomId': 1,
      'roomNumber': '101',
      'roomTypeName': 'Standard',
      'roomTypeSlug': 'standard',
      'checkIn': '2026-11-10',
      'checkOut': '2026-11-11',
      'guestCount': 1,
      'totalPrice': 300000,
      'status': 'Confirmed',
      'expiresAt': null,
      'createdAt': '2026-11-01T08:15:00Z',
      'nights': 1,
    };

    expect(Booking.fromJson(json).expiresAt, isNull);
    expect(
      () => Booking.fromJson({...json, 'status': 'Aneh'}),
      throwsFormatException,
    );
  });

  test('AuthResponse dan inisial nama', () {
    final auth = AuthResponse.fromJson({
      'token': 'abc.def.ghi',
      'expiresAtUtc': '2026-11-01T09:00:00Z',
      'userId': 'u-1',
      'fullName': 'Hasta Budiawan',
      'email': 'hasta@example.com',
      'roles': ['Guest'],
    });

    expect(auth.roles, ['Guest']);
    expect(auth.expiresAtUtc.isUtc, isTrue);

    final profile = UserProfile.fromJson({
      'id': 'u-1',
      'fullName': 'Hasta Budiawan',
      'email': 'hasta@example.com',
      'roles': ['Guest'],
    });
    expect(profile.initials, 'HB');
  });

  test('toApiDate dan parseApiDate saling berbalik', () {
    final date = DateTime(2026, 3, 5);
    expect(toApiDate(date), '2026-03-05');
    expect(parseApiDate('2026-03-05'), date);
  });
}
