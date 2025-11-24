import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models.dart';

class TmdbService {
  // TODO: Replace with your actual TMDB API key
  static const String _apiKey = 'Please Enter Your API KEY HERE';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBase = 'https://image.tmdb.org/t/p/w500';

  Future<List<ContentItem>> fetchTrendingMovies({int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl/trending/movie/week?api_key=$_apiKey&language=en-US&page=$page',
    );
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('TMDB movies error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? []);

    return results
        .map((e) => _mapMovieToContent(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ContentItem>> fetchTrendingTv({int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl/trending/tv/week?api_key=$_apiKey&language=en-US&page=$page',
    );
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('TMDB tv error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? []);

    return results
        .map((e) => _mapTvToContent(e as Map<String, dynamic>))
        .toList();
  }

  ContentItem _mapMovieToContent(Map<String, dynamic> json) {
    final posterPath = json['poster_path'] as String?;
    final title = json['title']?.toString() ?? json['name']?.toString() ?? '';

    return ContentItem(
      id:
          json['id'] is int
              ? json['id'] as int
              : int.tryParse('${json['id']}') ?? 0,
      name: title,
      type: 'movie',
      genres: '', // could be enhanced with genre lookups
      overview: json['overview']?.toString() ?? '',
      posterUrl: posterPath == null ? '' : '$_imageBase$posterPath',
      runtime: null,
    );
  }

  ContentItem _mapTvToContent(Map<String, dynamic> json) {
    final posterPath = json['poster_path'] as String?;
    final title =
        json['name']?.toString() ?? json['original_name']?.toString() ?? '';

    return ContentItem(
      id:
          json['id'] is int
              ? json['id'] as int
              : int.tryParse('${json['id']}') ?? 0,
      name: title,
      type: 'webseries',
      genres: '',
      overview: json['overview']?.toString() ?? '',
      posterUrl: posterPath == null ? '' : '$_imageBase$posterPath',
      runtime: null,
    );
  }
}
