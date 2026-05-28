import '../local/cache_local_service.dart';
import '../models/shloka_model.dart';
import 'api_service.dart';

class GitaRepository {
  GitaRepository(this._apiService, this._cache);

  final ApiService _apiService;
  final CacheLocalService _cache;
  final Map<int, List<ShlokaModel>> _chapterMemoryCache = {};
  final Map<int, Future<List<ShlokaModel>>> _chapterRequests = {};
  ShlokaModel? _dailyMemoryCache;
  Future<ShlokaModel?>? _dailyRequest;

  Future<ShlokaModel?> getDailyShloka() async {
    if (_dailyMemoryCache != null) return _dailyMemoryCache;

    final cached = _cache.getDailyShloka();
    if (cached != null) {
      _dailyMemoryCache = _parseShloka(cached);
      return _dailyMemoryCache;
    }

    if (_dailyRequest != null) return _dailyRequest!;
    _dailyRequest = _fetchDailyShloka();
    try {
      return await _dailyRequest!;
    } finally {
      _dailyRequest = null;
    }
  }

  Future<ShlokaModel?> _fetchDailyShloka() async {
    final response = await _apiService.getDailyShloka();
    if (!response.success || response.data == null) {
      final stale = _cache.getDailyShloka(allowExpired: true);
      return stale == null ? null : _parseShloka(stale);
    }

    final data = response.data;
    final map = data is Map ? (data['shloka'] ?? data) : data;
    if (map is! Map) return null;
    final shloka = _parseShloka(Map<String, dynamic>.from(map));
    if (shloka != null) {
      _dailyMemoryCache = shloka;
      await _cache.saveDailyShloka(shloka.toJson());
    }
    return shloka;
  }

  Future<List<ShlokaModel>> getChapterShlokas(int chapter) async {
    final memory = _chapterMemoryCache[chapter];
    if (memory != null) return memory;

    final cached = _cache.getChapter(chapter);
    if (cached != null) {
      final shlokas = _parseShlokaList(cached);
      _chapterMemoryCache[chapter] = shlokas;
      return shlokas;
    }

    final pending = _chapterRequests[chapter];
    if (pending != null) return pending;
    final request = _fetchChapterShlokas(chapter);
    _chapterRequests[chapter] = request;
    try {
      return await request;
    } finally {
      _chapterRequests.remove(chapter);
    }
  }

  Future<String?> getChapterVideoUrl(int chapter) async {
    final response = await _apiService.getChapterVideo(chapter);
    if (!response.success || response.data == null) return null;

    return _extractFullUrl(response.data);
  }

  Future<List<ShlokaModel>> _fetchChapterShlokas(int chapter) async {
    final response = await _apiService.getChapterShlokas(chapter);
    if (!response.success || response.data == null) {
      return _parseShlokaList(_cache.getChapter(chapter) ?? const []);
    }

    final data = response.data;
    final rawList = data is Map ? (data['shlokas'] ?? data['data']) : data;
    if (rawList is! List) return [];

    final shlokas = _parseShlokaList(
      rawList
          .whereType<Map>()
          .map((s) => Map<String, dynamic>.from(s))
          .toList(),
    );
    _chapterMemoryCache[chapter] = shlokas;
    await _cache.saveChapter(
      chapter,
      shlokas.map((shloka) => shloka.toJson()).toList(),
    );
    return shlokas;
  }

  ShlokaModel? _parseShloka(Map<String, dynamic> map) {
    try {
      return ShlokaModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  List<ShlokaModel> _parseShlokaList(List<Map<String, dynamic>> maps) {
    return maps.map(_parseShloka).whereType<ShlokaModel>().toList();
  }

  String? _extractFullUrl(dynamic data) {
    if (data is! Map) return null;

    final fullUrl = data['full_url'];
    if (fullUrl is String && fullUrl.trim().isNotEmpty) {
      return fullUrl.trim();
    }

    final nestedData = data['data'];
    final nestedUrl = _extractFullUrl(nestedData);
    if (nestedUrl != null) return nestedUrl;

    return _extractFullUrl(data['video']);
  }
}
