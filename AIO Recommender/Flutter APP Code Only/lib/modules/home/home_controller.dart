import 'package:get/get.dart';
import '../../data/api_service.dart';
import '../../data/models.dart';

class HomeController extends GetxController {
  RxString lastQuery = ''.obs;

  final ApiService apiService;

  HomeController(this.apiService);

  final query = ''.obs;
  final selectedType = 'mixed'.obs; // mixed | movie | anime | webseries
  final isLoading = false.obs;
  final error = ''.obs;

  final recommendations = <ContentItem>[].obs;
  final resolvedTitle = ''.obs;

  Future<void> fetchRecommendations({String? overrideTitle}) async {
    final title = (overrideTitle ?? query.value).trim();
    if (title.isEmpty) {
      error.value = 'Please type a title';
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final resp = await apiService.getRecommendations(
        title: title,
        type: selectedType.value == 'mixed' ? null : selectedType.value,
        model: 'hybrid',
        topn: 20,
      );

      recommendations.assignAll(resp.results);
      resolvedTitle.value =
          resp.resolvedTitle.isNotEmpty ? resp.resolvedTitle : resp.query;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void changeType(String type) {
    selectedType.value = type;
    if (query.value.trim().isNotEmpty) {
      fetchRecommendations();
    }
  }
}
