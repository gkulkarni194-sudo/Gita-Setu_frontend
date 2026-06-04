import 'api_service.dart';
import '../models/api_response.dart';

class AiRepository {
  AiRepository(this._apiService);

  final ApiService _apiService;
  final Map<String, Future<ApiResponse<dynamic>>> _sessionCache = {};

  Future<ApiResponse<dynamic>> analyzeMood(String input) {
    final normalized = input.trim();
    return _cached('mood:$normalized', () {
      return _apiService
          .analyzeMood({'input': normalized})
          .then(_withSuggestedShlokasList);
    });
  }

  Future<ApiResponse<dynamic>> explainShloka({
    int? chapter,
    int? verse,
    required String question,
    required List<Map<String, String>> history,
  }) {
    final normalized = question.trim();
    final historyKey = history
        .map((item) => '${item['question'] ?? ''}:${item['answer'] ?? ''}')
        .join('|');
    return _cached(
        'explain:${chapter ?? "general"}:${verse ?? "general"}:$normalized:$historyKey',
        () {
      final payload = <String, dynamic>{
        'input': normalized,
      };
      if (chapter != null) payload['chapter'] = chapter;
      if (verse != null) payload['verse'] = verse;
      return _apiService.explainQuery(payload);
    });
  }

  ApiResponse<dynamic> _withSuggestedShlokasList(ApiResponse<dynamic> response) {
    final data = response.data;
    if (!response.success || data is! Map) return response;

    final normalizedData = Map<String, dynamic>.from(data);
    normalizedData['suggestedShlokas'] =
        normalizedData['suggestedShlokas'] is List
            ? normalizedData['suggestedShlokas']
            : const <dynamic>[];

    return ApiResponse<dynamic>(
      success: response.success,
      data: normalizedData,
      error: response.error,
    );
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
