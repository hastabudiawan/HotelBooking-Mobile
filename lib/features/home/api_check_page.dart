import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/format.dart';
import '../rooms/data/room_models.dart';
import '../rooms/data/rooms_repository.dart';

final _roomTypesCheckProvider = FutureProvider.autoDispose<List<RoomType>>(
  (ref) => ref.watch(roomsRepositoryProvider).getRoomTypes(),
);

// SEMENTARA: bukti bahwa aplikasi bisa memanggil backend. Diganti di Part 04.
class ApiCheckPage extends ConsumerWidget {
  const ApiCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomTypes = ref.watch(_roomTypesCheckProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('API check')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('API: ${AppConfig.apiUrl}'),
            ),
            Expanded(
              child: roomTypes.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error.toString(), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () =>
                              ref.invalidate(_roomTypesCheckProvider),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (items) => ListView(
                  children: [
                    for (final room in items)
                      ListTile(
                        title: Text(room.name),
                        subtitle: Text(
                          '${formatRupiah(room.basePrice)} / night'
                          ' · up to ${room.capacity} guests',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
