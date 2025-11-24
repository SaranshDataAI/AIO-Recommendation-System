// ignore_for_file: unused_import

import '../../widgets/animated_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/api_service.dart';
import '../home/home_controller.dart';
import '../home/widgets/poster_card.dart';
import '../home/widgets/type_filter_chips.dart';

/// Discover page - dedicated search + AI recommendations.
/// Home remains a trending hub; this page shows results only.
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    // HomeController is reused here purely for search + recommendations.
    final HomeController controller = Get.put(HomeController(ApiService()));

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
              final bool isWide = constraints.maxWidth > 900;

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 24),
                    _buildSearchSection(theme, controller),
                    const SizedBox(height: 20),
                    _buildStatusRow(controller),
                    const SizedBox(height: 16),
                    Expanded(
                      child: AnimatedSection(
                        index: 0,
                        child: _buildResultsGrid(isWide, controller),
                      ),
                    ),
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
        const Icon(Icons.search_rounded, size: 26),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discover',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Search smarter across movies, anime & webseries.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.72),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchSection(ThemeData theme, HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1120), Color(0xFF020617)],
        ),
        border: Border.all(
          color: const Color(0xFFFF6FD8).withOpacity(0.25),
          width: 1.1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF00F5A0),
            blurRadius: 22,
            spreadRadius: 0.2,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search any title',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => TextField(
                    onChanged: controller.query.call,
                    onSubmitted: (_) => controller.fetchRecommendations(),
                    decoration: InputDecoration(
                      hintText:
                          'Try "Breaking Bad", "Your Name", "Inception"...',
                      suffixIcon:
                          controller.query.value.isEmpty
                              ? null
                              : IconButton(
                                onPressed: () {
                                  controller.query.value = '';
                                },
                                icon: const Icon(Icons.clear_rounded, size: 18),
                              ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : () => controller.fetchRecommendations(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ED82),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child:
                        controller.isLoading.value
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                            : const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Filter by type',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TypeFilterChips(controller: controller),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(HomeController controller) {
    return Obx(() {
      if (controller.error.value.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.error.value,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () => controller.fetchRecommendations(),
                child: const Text('Retry', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      }

      if (controller.recommendations.isEmpty) {
        return const SizedBox.shrink();
      }

      final String title =
          controller.lastQuery.value.isEmpty
              ? 'your taste'
              : controller.lastQuery.value;

      return Row(
        children: [
          Text(
            'Top picks for',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '"$title"',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildResultsGrid(bool isWide, HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.recommendations.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.recommendations.isEmpty) {
        return Center(
          child: Opacity(
            opacity: 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.search_rounded, size: 40),
                SizedBox(height: 8),
                Text(
                  'Start by searching for any movie, anime or webseries.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }

      final crossAxisCount = isWide ? 6 : 3;
      final aspectRatio = isWide ? 2 / 3.2 : 2 / 3.1;

      return GridView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: aspectRatio,
        ),
        itemCount: controller.recommendations.length,
        itemBuilder: (context, index) {
          final item = controller.recommendations[index];
          return PosterCard(item: item);
        },
      );
    });
  }
}

/// Simple fade + slide-up animation wrapper.
class AnimatedSection extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedSection({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 450 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
