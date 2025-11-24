import '../../widgets/animated_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/tmdb_service.dart';
import '../history/history_controller.dart';
import '../history/widgets/history_card.dart';
import '../watchlist/watchlist_controller.dart';
import '../watchlist/widgets/watchlist_card.dart';
import 'trending_controller.dart';
import '../settings/settings_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HistoryController historyController = Get.put(HistoryController());
  final WatchlistController watchlistController = Get.put(
    WatchlistController(),
  );
  final TrendingController trendingController = Get.put(
    TrendingController(TmdbService()),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF050A0F), Color(0xFF020617)],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 24),
                    AnimatedSection(
                      index: 0,
                      child: _buildTrendingMoviesSection(),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSection(index: 1, child: _buildTrendingTvSection()),
                    const SizedBox(height: 24),
                    AnimatedSection(
                      index: 2,
                      child: _buildContinueWatchingSection(),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSection(index: 3, child: _buildMyListSection()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Text(
          "🔥 Trending Now",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Get.to(() => const SettingsPage()),
          icon: const Icon(Icons.settings, size: 22),
        ),
      ],
    );
  }

  Widget _buildTrendingMoviesSection() {
    return Obx(() {
      final items = trendingController.trendingMovies;
      if (trendingController.isLoadingMovies.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (items.isEmpty) return const SizedBox.shrink();

      return _carousel(
        title: "Trending Movies 🎬",
        items: items.map((i) => HistoryCard(item: i)).toList(),
      );
    });
  }

  Widget _buildTrendingTvSection() {
    return Obx(() {
      final items = trendingController.trendingTv;
      if (trendingController.isLoadingTv.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (items.isEmpty) return const SizedBox.shrink();

      return _carousel(
        title: "Trending Webseries 📺",
        items: items.map((i) => HistoryCard(item: i)).toList(),
      );
    });
  }

  Widget _buildContinueWatchingSection() {
    return Obx(() {
      final items = historyController.items;
      if (items.isEmpty) return const SizedBox.shrink();

      return _carousel(
        title: "Continue Watching 🔁",
        items: items.map((i) => HistoryCard(item: i)).toList(),
      );
    });
  }

  Widget _buildMyListSection() {
    return Obx(() {
      final items = watchlistController.items;
      if (items.isEmpty) return const SizedBox.shrink();

      return _carousel(
        title: "My List ⭐",
        items: items.map((i) => WatchlistCard(item: i)).toList(),
      );
    });
  }

  Widget _carousel({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => items[index],
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }
}
