import '../local/cache_local_service.dart';
import '../models/guru.dart';
import 'api_service.dart';

class GuruRepository {
  GuruRepository(this._apiService, this._cache);

  final ApiService _apiService;
  final CacheLocalService _cache;
  List<Guru>? _guruMemoryCache;
  Future<List<Guru>>? _guruRequest;

  Future<List<Guru>> getGurus() async {
    if (_guruMemoryCache != null) return _guruMemoryCache!;

    final cached = _cache.getGuruList();
    if (cached != null) {
      _guruMemoryCache = _parseGuruList(cached);
      return _guruMemoryCache!;
    }

    if (_guruRequest != null) return _guruRequest!;
    _guruRequest = _fetchGurus();
    try {
      return await _guruRequest!;
    } finally {
      _guruRequest = null;
    }
  }

  Future<List<Guru>> _fetchGurus() async {
    final response = await _apiService.getGurus();
    if (!response.success || response.data == null) {
      return _parseGuruList(_cache.getGuruList(allowExpired: true) ?? const []);
    }

    final data = response.data;
    final List<dynamic> items;
    if (data is List) {
      items = data;
    } else if (data is Map) {
      final rawItems = data['gurus'] ?? data['mentors'];
      items = rawItems is List ? rawItems : const <dynamic>[];
    } else {
      items = const <dynamic>[];
    }

    final gurus = _parseGuruList(items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList());
    _guruMemoryCache = gurus;
    await _cache.saveGuruList(gurus.map((guru) => guru.toJson()).toList());
    return gurus;
  }

  Future<Guru> addGuru(Guru guru) async {
    final response = await _apiService.addGuru(guru.toJson());
    if (response.success && response.data is Map) {
      final saved = Guru.fromJson(Map<String, dynamic>.from(response.data));
      final gurus = [...(_guruMemoryCache ?? await getGurus()), saved];
      _guruMemoryCache = gurus;
      await _cache.saveGuruList(gurus.map((item) => item.toJson()).toList());
      return saved;
    }
    return guru;
  }

  List<Guru> _parseGuruList(List<Map<String, dynamic>> maps) {
    return maps
        .map((item) {
          try {
            return Guru.fromJson(item);
          } catch (_) {
            return null;
          }
        })
        .whereType<Guru>()
        .toList();
  }
}
