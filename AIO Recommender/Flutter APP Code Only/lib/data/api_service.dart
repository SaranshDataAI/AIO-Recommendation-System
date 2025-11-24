import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  static const String baseUrl = 'https://aio-backend-server.onrender.com';

  Future<RecommendationResponse> getRecommendations({
    required String title,
    String? type, // "movie" | "anime" | "webseries" | null (mixed)
    String model = 'hybrid',
    int topn = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/recommend');

    final body = {'title': title, 'model': model, 'topn': topn};

    if (type != null && type.isNotEmpty && type != 'mixed') {
      body['type'] = type;
    }

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return RecommendationResponse.fromJson(data);
    } else {
      throw Exception(
        'Failed: ${res.statusCode} ${res.reasonPhrase} ${res.body}',
      );
    }
  }
}
