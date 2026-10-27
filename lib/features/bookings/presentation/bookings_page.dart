import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/error_view.dart';
import '../application/booking_providers.dart';
import '../domain/booking_rules.dart';
import 'widgets/booking_row.dart';
import 'widgets/segmented_tabs.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> {
  // 0 = Active, 1 = Past.
  int _tab = 0;

  Future<void> _refresh() async {
    ref.invalidate(myBookingsProvider);
    try {
      await ref.read(myBookingsProvider.future);
    } catch (_) {
      // Error ditampilkan oleh daftar sendiri.
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(myBookingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(showLocation: false),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedTabs(
                labels: const ['Active', 'Past'],
                selected: _tab,
                onChanged: (index) => setState(() => _tab = index),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: bookings.when(
                skipLoadingOnReload: true,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ErrorView(error: error, onRetry: _refresh),
                data: (items) {
                  final now = DateTime.now().toUtc();
                  final isActiveTab = _tab == 0;
                  final visible = isActiveTab
                      ? activeBookings(items, now)
                      : pastBookings(items, now);

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: visible.isEmpty
                        ? _EmptyState(isActiveTab: isActiveTab)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: visible.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) => BookingRow(
                              booking: visible[index],
                              status: effectiveStatus(visible[index], now),
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isActiveTab});

  final bool isActiveTab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Text(
          isActiveTab ? 'No active bookings.' : 'No past bookings yet.',
          textAlign: TextAlign.center,
        ),
        if (isActiveTab) ...[
          const SizedBox(height: 16),
          Center(
            child: FilledButton(
              onPressed: () => context.go('/rooms'),
              style: FilledButton.styleFrom(minimumSize: const Size(160, 44)),
              child: const Text('Find a room'),
            ),
          ),
        ],
      ],
    );
  }
}
