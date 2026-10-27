import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/back_scaffold.dart';
import '../../../core/widgets/error_view.dart';
import '../../auth/application/auth_controller.dart';
import '../../rooms/application/rooms_providers.dart';
import '../../rooms/data/room_models.dart';
import '../../rooms/presentation/widgets/room_image.dart';
import '../application/availability.dart';
import '../data/bookings_repository.dart';
import '../domain/stay_rules.dart';
import 'widgets/booking_form_widgets.dart';
import '../application/booking_providers.dart';

class BookRoomPage extends ConsumerWidget {
  const BookRoomPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final room = ref.watch(roomTypeBySlugProvider(slug));

    Widget body;
    if (user == null) {
      // Router mengalihkan ke Sign in. Ini hanya pengaman.
      body = const SizedBox.shrink();
    } else if (!user.isGuest) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Guest accounts only.\n\n'
            'Staff accounts cannot book rooms. Log out and use a guest '
            'account to make a booking.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      body = room.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(roomTypeBySlugProvider(slug)),
        ),
        data: (data) => data == null
            ? const Center(child: Text('This room could not be found.'))
            : _BookingForm(room: data),
      );
    }

    return BackScaffold(
      title: 'Book room',
      fallbackLocation: '/rooms/$slug',
      child: body,
    );
  }
}

class _BookingForm extends ConsumerStatefulWidget {
  const _BookingForm({required this.room});

  final RoomType room;

  @override
  ConsumerState<_BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends ConsumerState<_BookingForm> {
  late DateTime _checkIn;
  late DateTime _checkOut;
  late int _guests;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final today = hotelToday();
    _checkIn = addDays(today, 1);
    _checkOut = addDays(today, 2);
    _guests = widget.room.capacity < 2 ? widget.room.capacity : 2;
  }

  AvailabilityQuery get _query => (
    slug: widget.room.slug,
    checkIn: _checkIn,
    checkOut: _checkOut,
    guests: _guests,
  );

  Future<void> _pickCheckIn() async {
    final today = hotelToday();
    final picked = await showDatePicker(
      context: context,
      helpText: 'Check-in',
      initialDate: _checkIn.isBefore(today) ? today : _checkIn,
      firstDate: today,
      lastDate: addDays(today, 365),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _checkIn = picked;
      // Check-out harus tetap setelah check-in dan tidak melebihi batas malam.
      if (!_checkOut.isAfter(picked) ||
          nightsBetween(picked, _checkOut) > maxNights) {
        _checkOut = addDays(picked, 1);
      }
      _error = null;
    });
  }

  Future<void> _pickCheckOut() async {
    final picked = await showDatePicker(
      context: context,
      helpText: 'Check-out',
      initialDate: _checkOut,
      firstDate: addDays(_checkIn, 1),
      lastDate: addDays(_checkIn, maxNights),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _checkOut = picked;
      _error = null;
    });
  }

  Future<void> _confirm() async {
    if (_submitting) return;
    final query = _query;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final booking = await ref
          .read(bookingsRepositoryProvider)
          .create(
            roomTypeId: widget.room.id,
            checkIn: query.checkIn,
            checkOut: query.checkOut,
            guestCount: query.guests,
          );
      ref.invalidate(myBookingsProvider);
      if (!mounted) return;
      context.go('/bookings/${booking.id}');
    } on ApiException catch (error) {
      // Kamar mungkin baru saja diambil orang lain: cek ulang ketersediaan.
      ref.invalidate(availabilityProvider(query));
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final query = _query;
    final availability = ref.watch(availabilityProvider(query));
    final canConfirm =
        !_submitting &&
        availability.maybeWhen(
          data: (value) => value is RoomAvailable,
          orElse: () => false,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _RoomHeader(room: room),
        const SizedBox(height: 24),
        Text('Dates', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DateField(
                label: 'Check-in',
                date: _checkIn,
                onTap: _pickCheckIn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DateField(
                label: 'Check-out',
                date: _checkOut,
                onTap: _pickCheckOut,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Guests', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        GuestStepper(
          value: _guests,
          max: room.capacity,
          onChanged: (value) => setState(() {
            _guests = value;
            _error = null;
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(
            'This room fits up to ${plural(room.capacity, 'guest')}.',
            style: TextStyle(fontSize: 12, color: mutedColor(context)),
          ),
        ),
        const SizedBox(height: 24),
        availability.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(availabilityProvider(query)),
          ),
          data: (value) => switch (value) {
            RoomAvailable(:final item) => _AvailableSummary(item: item),
            RoomUnavailable() => const _Notice(
              'This room is not available for these dates and number of '
              'guests. Try other dates.',
            ),
            StayInvalid(:final message) => _Notice(message),
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Your room is held for 15 minutes after you confirm. '
          'Pay before the time runs out, or the booking expires.',
          style: TextStyle(fontSize: 12, color: mutedColor(context)),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: canConfirm ? _confirm : null,
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Confirm booking'),
        ),
      ],
    );
  }
}

class _RoomHeader extends StatelessWidget {
  const _RoomHeader({required this.room});

  final RoomType room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 80,
            height: 80,
            child: RoomImage(slug: room.slug, imageUrl: room.imageUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(room.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${formatRupiah(room.basePrice)} / night'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvailableSummary extends StatelessWidget {
  const _AvailableSummary({required this.item});

  final AvailableRoomType item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 18),
              SizedBox(width: 8),
              Text('Available', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          SummaryLine(
            label:
                '${formatRupiah(item.pricePerNight)} × ${plural(item.nights, 'night')}',
            value: formatRupiah(item.totalPrice),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          SummaryLine(
            label: 'Total',
            value: formatRupiah(item.totalPrice),
            bold: true,
          ),
          if (item.availableRooms <= 2)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Only ${plural(item.availableRooms, 'room')} left for these dates.',
                style: const TextStyle(fontSize: 12, color: AppColors.danger),
              ),
            ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message),
    );
  }
}
