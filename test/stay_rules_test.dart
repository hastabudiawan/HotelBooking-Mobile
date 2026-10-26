import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/core/utils/dates.dart';
import 'package:paradise_view/features/bookings/domain/stay_rules.dart';

void main() {
  final today = DateTime(2026, 11, 10);

  group('validateStay', () {
    test('rentang valid menghasilkan null', () {
      expect(validateStay(today, DateTime(2026, 11, 11), today), isNull);
    });

    test('check-in sebelum hari ini ditolak', () {
      expect(
        validateStay(DateTime(2026, 11, 9), DateTime(2026, 11, 11), today),
        'Check-in cannot be before today.',
      );
    });

    test('check-out sama dengan atau sebelum check-in ditolak', () {
      expect(
        validateStay(today, today, today),
        'Check-out must be after check-in.',
      );
      expect(
        validateStay(DateTime(2026, 11, 12), DateTime(2026, 11, 11), today),
        'Check-out must be after check-in.',
      );
    });

    test('tepat 30 malam boleh, 31 malam ditolak', () {
      expect(validateStay(today, addDays(today, 30), today), isNull);
      expect(
        validateStay(today, addDays(today, 31), today),
        'You can stay for up to 30 nights.',
      );
    });
  });

  group('tanggal', () {
    test('hotelToday memakai WIB (UTC+7)', () {
      // 18.30 UTC tanggal 26 sudah 01.30 WIB tanggal 27.
      expect(
        hotelToday(now: DateTime.utc(2026, 10, 26, 18, 30)),
        DateTime(2026, 10, 27),
      );
      // 16.30 UTC masih 23.30 WIB di hari yang sama.
      expect(
        hotelToday(now: DateTime.utc(2026, 10, 26, 16, 30)),
        DateTime(2026, 10, 26),
      );
    });

    test('addDays melewati pergantian bulan dan tahun', () {
      expect(addDays(DateTime(2026, 10, 31), 1), DateTime(2026, 11, 1));
      expect(addDays(DateTime(2026, 12, 31), 1), DateTime(2027, 1, 1));
      expect(addDays(DateTime(2026, 3, 1), -1), DateTime(2026, 2, 28));
    });

    test('nightsBetween menghitung malam', () {
      expect(nightsBetween(DateTime(2026, 11, 10), DateTime(2026, 11, 12)), 2);
      expect(nightsBetween(DateTime(2026, 10, 30), DateTime(2026, 11, 2)), 3);
    });
  });
}
