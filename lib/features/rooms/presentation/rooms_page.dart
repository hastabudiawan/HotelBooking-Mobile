import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/error_view.dart';
import '../application/rooms_providers.dart';
import 'widgets/category_tabs.dart';
import 'widgets/room_card.dart';
import 'widgets/room_search_field.dart';

class RoomsPage extends ConsumerStatefulWidget {
  const RoomsPage({super.key});

  @override
  ConsumerState<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends ConsumerState<RoomsPage> {
  late final TextEditingController _search;
  // Null berarti tab "All".
  String? _slug;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: ref.read(roomSearchProvider));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(roomTypesProvider);
    try {
      await ref.read(roomTypesProvider.future);
    } catch (_) {
      // Error ditampilkan oleh daftar kamar sendiri.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kata dari kolom pencarian di Home ikut mengisi kolom di sini.
    ref.listen<String>(roomSearchProvider, (previous, next) {
      if (_search.text != next) _search.text = next;
    });

    final rooms = ref.watch(roomTypesProvider);
    final query = ref.watch(roomSearchProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const SizedBox(height: 8),
            RoomSearchField(
              controller: _search,
              hint: 'Search for a room',
              onChanged: (value) =>
                  ref.read(roomSearchProvider.notifier).set(value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: rooms.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ErrorView(error: error, onRetry: _refresh),
                data: (items) {
                  // Tab dibuat dari tipe kamar. Kalau tipe yang dipilih sudah
                  // tidak ada (misalnya dihapus admin), kembali ke "All".
                  final slugs = [for (final room in items) room.slug];
                  final activeSlug = slugs.contains(_slug) ? _slug : null;
                  final selected = activeSlug == null
                      ? 0
                      : slugs.indexOf(activeSlug) + 1;

                  final visible = filterRoomTypes(
                    items,
                    query: query,
                    slug: activeSlug,
                  );

                  return Column(
                    children: [
                      CategoryTabs(
                        labels: ['All', for (final room in items) room.name],
                        selected: selected,
                        onSelected: (index) => setState(
                          () => _slug = index == 0 ? null : slugs[index - 1],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refresh,
                          child: visible.isEmpty
                              ? ListView(
                                  children: const [
                                    SizedBox(height: 80),
                                    Center(
                                      child: Text(
                                        'No rooms match your search.',
                                      ),
                                    ),
                                  ],
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 0.8,
                                      ),
                                  itemCount: visible.length,
                                  itemBuilder: (context, index) => RoomCard(
                                    room: visible[index],
                                    compact: true,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
