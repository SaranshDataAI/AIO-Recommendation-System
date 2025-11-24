import 'package:get/get.dart';
import '../../data/models.dart';
import '../../services/history_service.dart';

class HistoryController extends GetxController {
  final items = <ContentItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final results = await HistoryService.getHistory(limit: 20);
      items.assignAll(results);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshHistory() async {
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await HistoryService.clearHistory();
    items.clear();
  }
}
