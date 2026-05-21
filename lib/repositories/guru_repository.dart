import '../models/guru.dart';
import 'api_service.dart';

class GuruRepository {
  GuruRepository(this._apiService);

  final ApiService _apiService;

  Future<List<Guru>> getGurus() async {
    final response = await _apiService.getGurus();
    if (!response.success || response.data == null) return [];
    final data = response.data;
    final List<dynamic> items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['gurus'] is List) {
      items = data['gurus'] as List;
    } else if (data is Map && data['mentors'] is List) {
      items = data['mentors'] as List;
    } else {
      items = const <dynamic>[];
    }

    return items
        .whereType<Map>()
        .map((item) => Guru.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Guru> addGuru(Guru guru) async {
    final response = await _apiService.addGuru(guru.toJson());
    if (response.success && response.data is Map) {
      return Guru.fromJson(Map<String, dynamic>.from(response.data));
    }
    return guru;
  }
}
