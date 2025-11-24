import 'package:get/get.dart';
import '../../data/models.dart';
import '../../services/watchlist_service.dart';

class WatchlistController extends GetxController {
  final items = <ContentItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWatchlist();
  }

  Future<void> loadWatchlist() async {
    isLoading.value = true;
    try {
      final results = await WatchlistService.getWatchlist();
      items.assignAll(results);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshWatchlist() async {
    await loadWatchlist();
  }

  Future<void> clearWatchlist() async {
    await WatchlistService.clearWatchlist();
    items.clear();
  }
}
