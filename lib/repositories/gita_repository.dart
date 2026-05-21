import '../models/shloka_model.dart';
import 'api_service.dart';

class GitaRepository {
  GitaRepository(this._apiService);

  final ApiService _apiService;

  Future<ShlokaModel?> getDailyShloka() async {
    final response = await _apiService.getDailyShloka();
    if (!response.success || response.data == null) return null;
    final data = response.data;
    final map = data is Map ? (data['shloka'] ?? data) : data;
    if (map is! Map) return null;
    try {
      return ShlokaModel.fromJson(Map<String, dynamic>.from(map));
    } catch (_) {
      return null;
    }
  }

  Future<List<ShlokaModel>> getChapterShlokas(int chapter) async {
    final response = await _apiService.getChapterShlokas(chapter);
    if (!response.success || response.data == null) return [];
    
    final data = response.data;
    final rawList = data is Map ? (data['shlokas'] ?? data['data']) : data;
    if (rawList is! List) return [];
    
    return rawList
        .whereType<Map>()
        .map((s) => ShlokaModel.fromJson(Map<String, dynamic>.from(s)))
        .toList();
  }
}
