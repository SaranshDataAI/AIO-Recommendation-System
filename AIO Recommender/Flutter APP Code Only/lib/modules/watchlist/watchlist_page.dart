import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models.dart';
import 'watchlist_controller.dart';
import '../home/widgets/poster_card.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final WatchlistController controller = Get.put(WatchlistController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My List'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Clear My List',
            onPressed: () async {
              await controller.clearWatchlist();
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value && controller.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = controller.items;

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Your list is empty. Add shows and movies from the detail page.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshWatchlist,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                childAspectRatio: 2 / 3.1,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final ContentItem item = items[index];
                return PosterCard(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}
