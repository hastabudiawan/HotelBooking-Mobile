import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/providers.dart';
import '../../../core/utils/dates.dart';
import 'booking_models.dart';

class BookingsRepository {
  BookingsRepository(this._api);

  final ApiClient _api;

  Booking _booking(Object? json) =>
      Booking.fromJson(json as Map<String, dynamic>);

  Future<Booking> create({
    required int roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestCount,
  }) {
    return _api.post(
      '/api/bookings',
      body: {
        'roomTypeId': roomTypeId,
        'checkIn': toApiDate(checkIn),
        'checkOut': toApiDate(checkOut),
        'guestCount': guestCount,
      },
      parse: _booking,
    );
  }

  Future<List<Booking>> mine() {
    return _api.get(
      '/api/bookings/my',
      parse: (json) => (json as List).map(_booking).toList(),
    );
  }

  // Null kalau booking tidak ada atau bukan milik pengguna (404).
  Future<Booking?> getById(int id) async {
    try {
      return await _api.get('/api/bookings/$id', parse: _booking);
    } on ApiException catch (error) {
      if (error.isNotFound) return null;
      rethrow;
    }
  }

  Future<List<Payment>> payments(int id) {
    return _api.get(
      '/api/bookings/$id/payments',
      parse: (json) => (json as List)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<PaymentResult> pay(
    int id, {
    required PaymentMethod method,
    bool simulateFailure = false,
  }) {
    return _api.post(
      '/api/bookings/$id/pay',
      body: {'method': method.apiValue, 'simulateFailure': simulateFailure},
      parse: (json) => PaymentResult.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<Booking> cancel(int id) {
    return _api.post('/api/bookings/$id/cancel', parse: _booking);
  }
}

final bookingsRepositoryProvider = Provider<BookingsRepository>(
  (ref) => BookingsRepository(ref.watch(apiClientProvider)),
);
