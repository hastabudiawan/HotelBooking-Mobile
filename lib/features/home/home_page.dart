import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/error_view.dart';
import '../rooms/application/rooms_providers.dart';
import '../rooms/presentation/widgets/category_tabs.dart';
import '../rooms/presentation/widgets/room_card.dart';
import '../rooms/presentation/widgets/room_search_field.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _pageController = PageController(viewportFraction: 0.82);
  final _search = TextEditingController();
  int _selected = 0;

  @override
  void dispose() {
    _pageController.dispose();
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

  void _submitSearch(String value) {
    ref.read(roomSearchProvider.notifier).set(value.trim());
    _search.clear();
    context.go('/rooms');
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomTypesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const AppHeader(showThemeToggle: true),
              const SizedBox(height: 8),
              RoomSearchField(
                controller: _search,
                hint: 'Search for a room',
                onSubmitted: _submitSearch,
              ),
              const SizedBox(height: 24),
              const _HeroBanner(),
              const SizedBox(height: 24),
              const _SectionTitle(),
              const SizedBox(height: 16),
              rooms.when(
                loading: () => const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SizedBox(
                  height: 300,
                  child: ErrorView(error: error, onRetry: _refresh),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('No rooms available yet.')),
                    );
                  }
                  final selected = _selected < items.length ? _selected : 0;

                  return Column(
                    children: [
                      CategoryTabs(
                        labels: [for (final room in items) room.name],
                        selected: selected,
                        onSelected: (index) => _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: PageView.builder(
                          controller: _pageController,
                          padEnds: false,
                          itemCount: items.length,
                          onPageChanged: (index) =>
                              setState(() => _selected = index),
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: RoomCard(room: items[index]),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 150,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/hero_home.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: AppColors.brand),
              ),
              Container(color: Colors.black.withValues(alpha: 0.3)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'A Hotel for every\nmoment rich in emotion.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go('/rooms'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.brand,
                      minimumSize: const Size(112, 36),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Book now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Choose a room',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: dark ? Colors.white : AppColors.brand,
              fontWeight: FontWeight.w500,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/rooms'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
              ),
              child: const Text('view all', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
