class ContentItem {
  final int id;
  final String name;
  final String type;
  final String genres;
  final String overview;
  final String posterUrl;
  final double? runtime;

  ContentItem({
    required this.id,
    required this.name,
    required this.type,
    required this.genres,
    required this.overview,
    required this.posterUrl,
    required this.runtime,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as int,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      genres: json['genres'] ?? '',
      overview: json['overview'] ?? '',
      posterUrl: json['poster_url'] ?? '',
      runtime:
          json['runtime'] == null ? null : (json['runtime'] as num).toDouble(),
    );
  }
}

class RecommendationResponse {
  final String query;
  final String resolvedTitle;
  final List<ContentItem> results;

  RecommendationResponse({
    required this.query,
    required this.resolvedTitle,
    required this.results,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    final list =
        (json['results'] as List<dynamic>? ?? [])
            .map((e) => ContentItem.fromJson(e as Map<String, dynamic>))
            .toList();

    return RecommendationResponse(
      query: json['query'] ?? '',
      resolvedTitle: json['resolved_title'] ?? '',
      results: list,
    );
  }
}
