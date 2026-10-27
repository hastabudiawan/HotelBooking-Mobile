import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/back_scaffold.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_view.dart';
import '../application/booking_providers.dart';
import '../data/booking_models.dart';
import '../data/bookings_repository.dart';
import '../domain/booking_rules.dart';
import 'widgets/booking_form_widgets.dart';
import 'widgets/countdown.dart';
import 'widgets/pay_form.dart';
import 'widgets/status_badge.dart';

class BookingDetailPage extends ConsumerStatefulWidget {
  const BookingDetailPage({super.key, required this.id});

  final int id;

  @override
  ConsumerState<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends ConsumerState<BookingDetailPage> {
  // Pita pesan sukses di atas halaman.
  String? _flash;

  bool _paying = false;
  String? _payError;

  bool _cancelling = false;
  String? _cancelError;

  void _refresh() {
    ref.invalidate(bookingProvider(widget.id));
    ref.invalidate(paymentsProvider(widget.id));
    // Daftar di tab Booking ikut diperbarui (status baru setelah bayar atau batal).
    ref.invalidate(myBookingsProvider);
  }

  Future<void> _pay(PaymentMethod method, bool simulateFailure) async {
    if (_paying) return;
    setState(() {
      _paying = true;
      _payError = null;
    });

    try {
      final result = await ref
          .read(bookingsRepositoryProvider)
          .pay(widget.id, method: method, simulateFailure: simulateFailure);
      if (!mounted) return;

      // Pembayaran ditolak dijawab 200 dengan status Failed, bukan error HTTP.
      if (result.payment.status == PaymentStatus.paid) {
        setState(() {
          _flash = 'Payment received. Your booking is confirmed. See you soon!';
        });
      } else {
        setState(() {
          _payError =
              'The payment was declined. You can try again before the time '
              'runs out.';
        });
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _payError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _payError = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _paying = false);
        // Status mungkin sudah berubah (dibayar, kedaluwarsa, dibatalkan).
        _refresh();
      }
    }
  }

  Future<void> _cancel(Booking booking) async {
    final confirmed = await showPillConfirmDialog(
      context,
      message: isRefundable(booking)
          ? 'Cancel this booking? Your payment will be refunded in full.'
          : 'Cancel this booking? The room will be released.',
      confirmLabel: 'Yes, cancel',
      cancelLabel: 'Keep booking',
    );
    if (!confirmed || !mounted) return;

    setState(() {
      _cancelling = true;
      _cancelError = null;
    });

    try {
      await ref.read(bookingsRepositoryProvider).cancel(widget.id);
      if (mounted) {
        setState(() {
          _flash =
              'Your booking has been cancelled. If you had paid, the payment '
              'was refunded.';
        });
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _cancelError = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _cancelError = 'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cancelling = false);
        _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider(widget.id));

    return BackScaffold(
      title: 'Booking details',
      fallbackLocation: '/bookings',
      child: booking.when(
        // Isi lama tetap tampil saat memuat ulang, supaya layar tidak berkedip.
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(error: error, onRetry: _refresh),
        data: (data) => data == null
            ? const Center(child: Text('Booking not found.'))
            : _content(context, data),
      ),
    );
  }

  Widget _content(BuildContext context, Booking booking) {
    final theme = Theme.of(context);
    final isPending = booking.status == BookingStatus.pending;
    final windowOpen = isPaymentWindowOpen(booking, DateTime.now().toUtc());

    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (_flash != null) _FlashBanner(_flash!),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking code',
                      style: TextStyle(
                        fontSize: 12,
                        color: mutedColor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.bookingCode,
                      style: theme.textTheme.titleLarge?.copyWith(
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: effectiveStatus(booking, DateTime.now().toUtc()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailsCard(booking: booking),
          if (isPending) ...[
            const SizedBox(height: 16),
            if (windowOpen)
              _PaySection(
                booking: booking,
                busy: _paying,
                error: _payError,
                onPay: _pay,
                onExpired: () {
                  setState(() {});
                  _refresh();
                },
              )
            else
              const _Panel(
                child: Text(
                  'The payment time for this booking has run out, so the room '
                  'was released. Please make a new booking.',
                ),
              ),
          ],
          if (canCancel(booking)) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _cancelling ? null : () => _cancel(booking),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: _cancelling
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cancel booking'),
            ),
            if (_cancelError != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _cancelError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
          ],
          _PaymentsSection(bookingId: booking.id),
        ],
      ),
    );
  }
}

class _FlashBanner extends StatelessWidget {
  const _FlashBanner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${booking.roomTypeName} room',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: dark ? Colors.white : AppColors.brand),
          ),
          const SizedBox(height: 16),
          SummaryLine(label: 'Room number', value: booking.roomNumber),
          const SizedBox(height: 10),
          SummaryLine(
            label: 'Check-in',
            value: formatDateShort(booking.checkIn),
          ),
          const SizedBox(height: 10),
          SummaryLine(
            label: 'Check-out',
            value: formatDateShort(booking.checkOut),
          ),
          const SizedBox(height: 10),
          SummaryLine(
            label: 'Stay',
            value:
                '${plural(booking.nights, 'night')}, '
                '${plural(booking.guestCount, 'guest')}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          SummaryLine(
            label: 'Total',
            value: formatRupiah(booking.totalPrice),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _PaySection extends StatelessWidget {
  const _PaySection({
    required this.booking,
    required this.busy,
    required this.error,
    required this.onPay,
    required this.onExpired,
  });

  final Booking booking;
  final bool busy;
  final String? error;
  final void Function(PaymentMethod method, bool simulateFailure) onPay;
  final VoidCallback onExpired;

  @override
  Widget build(BuildContext context) {
    // Pemanggil sudah memastikan expiresAt tidak null dan belum lewat.
    final expiresAt = booking.expiresAt!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFB7791F).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Pay within '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Countdown(expiresAt: expiresAt, onExpired: onExpired),
                ),
                TextSpan(
                  text:
                      ' to keep your room. It is held until '
                      '${formatDateTimeWib(expiresAt)}.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PayForm(
          amount: booking.totalPrice,
          busy: busy,
          error: error,
          onPay: onPay,
        ),
      ],
    );
  }
}

class _PaymentsSection extends ConsumerWidget {
  const _PaymentsSection({required this.bookingId});

  final int bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsProvider(bookingId));

    return payments.when(
      skipLoadingOnReload: true,
      loading: () => const SizedBox.shrink(),
      // Riwayat pembayaran hanya pelengkap, jadi error tidak ditampilkan.
      error: (error, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payments', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              for (final payment in items) _PaymentRow(payment: payment),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final color = switch (payment.status) {
      PaymentStatus.paid => AppColors.success,
      PaymentStatus.failed => AppColors.danger,
      PaymentStatus.refunded => const Color(0xFF2B7CB3),
      PaymentStatus.pending => const Color(0xFFB7791F),
    };
    final paidAt = payment.paidAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatRupiah(payment.amount)} via ${payment.method}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (paidAt != null)
                  Text(
                    formatDateTimeWib(paidAt),
                    style: TextStyle(fontSize: 12, color: mutedColor(context)),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              payment.status.name[0].toUpperCase() +
                  payment.status.name.substring(1),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
