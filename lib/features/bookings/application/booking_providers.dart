import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/booking_models.dart';
import '../data/bookings_repository.dart';

// Satu booking. Null kalau tidak ada, bukan milik pengguna (404), atau akun
// staf (403): ketiganya tampil sebagai "tidak ditemukan".
final bookingProvider = FutureProvider.autoDispose.family<Booking?, int>((
  ref,
  id,
) async {
  try {
    return await ref.watch(bookingsRepositoryProvider).getById(id);
  } on ApiException catch (error) {
    if (error.statusCode == 403) return null;
    rethrow;
  }
});

final paymentsProvider = FutureProvider.autoDispose.family<List<Payment>, int>(
  (ref, id) => ref.watch(bookingsRepositoryProvider).payments(id),
);
