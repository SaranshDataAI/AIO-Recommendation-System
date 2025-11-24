import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models.dart';
import 'history_controller.dart';
import '../home/widgets/poster_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch History'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Clear history',
            onPressed: () async {
              await controller.clearHistory();
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = controller.items;

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'You have not watched anything yet.',
              style: TextStyle(fontSize: 14),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshHistory,
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
      }),
    );
  }
}
