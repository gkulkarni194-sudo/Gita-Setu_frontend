import 'api_service.dart';
import '../models/api_response.dart';

class AiRepository {
  AiRepository(this._apiService);

  final ApiService _apiService;

  Future<ApiResponse<dynamic>> analyzeMood(String input) {
    return _apiService.analyzeMood({'input': input});
  }

  Future<ApiResponse<dynamic>> explainShloka({
    required int chapter,
    required int verse,
    required String question,
    required List<Map<String, String>> history,
  }) {
    return _apiService.explainQuery({
      'chapter': chapter,
      'verse': verse,
      'question': question,
      'history': history,
    });
  }
}
