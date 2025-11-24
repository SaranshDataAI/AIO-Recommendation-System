import 'package:get/get.dart';
import '../../data/models.dart';
import '../../services/tmdb_service.dart';

class TrendingController extends GetxController {
  final TmdbService tmdbService;

  TrendingController(this.tmdbService);

  final trendingMovies = <ContentItem>[].obs;
  final trendingTv = <ContentItem>[].obs;

  final isLoadingMovies = false.obs;
  final isLoadingTv = false.obs;
  final errorMovies = ''.obs;
  final errorTv = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTrending();
  }

  Future<void> loadTrending() async {
    await Future.wait([_loadMovies(), _loadTv()]);
  }

  Future<void> _loadMovies() async {
    isLoadingMovies.value = true;
    errorMovies.value = '';
    try {
      final items = await tmdbService.fetchTrendingMovies(page: 1);
      trendingMovies.assignAll(items);
    } catch (e) {
      errorMovies.value = e.toString();
    } finally {
      isLoadingMovies.value = false;
    }
  }

  Future<void> _loadTv() async {
    isLoadingTv.value = true;
    errorTv.value = '';
    try {
      final items = await tmdbService.fetchTrendingTv(page: 1);
      trendingTv.assignAll(items);
    } catch (e) {
      errorTv.value = e.toString();
    } finally {
      isLoadingTv.value = false;
    }
  }
}
