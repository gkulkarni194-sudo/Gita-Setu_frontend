import 'api_service.dart';
import '../models/api_response.dart';

class AiRepository {
  AiRepository(this._apiService);

  final ApiService _apiService;
  final Map<String, Future<ApiResponse<dynamic>>> _sessionCache = {};

  Future<ApiResponse<dynamic>> analyzeMood(String input) {
    final normalized = input.trim();
    return _cached('mood:$normalized', () {
      return _apiService.analyzeMood({'input': normalized});
    });
  }

  Future<ApiResponse<dynamic>> explainShloka({
    required int chapter,
    required int verse,
    required String question,
    required List<Map<String, String>> history,
  }) {
    final normalized = question.trim();
    final historyKey = history
        .map((item) => '${item['question'] ?? ''}:${item['answer'] ?? ''}')
        .join('|');
    return _cached('explain:$chapter:$verse:$normalized:$historyKey', () {
      return _apiService.explainQuery({
        'chapter': chapter,
        'verse': verse,
        'question': normalized,
        'history': history,
      });
    });
  }

  Future<ApiResponse<dynamic>> _cached(
    String key,
    Future<ApiResponse<dynamic>> Function() request,
  ) async {
    final cached = _sessionCache[key];
    if (cached != null) return cached;

    final future = request();
    _sessionCache[key] = future;
    final response = await future;
    if (!response.success) {
      _sessionCache.remove(key);
    }
    return response;
  }
}
