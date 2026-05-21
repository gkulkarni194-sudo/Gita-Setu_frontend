import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

class CacheLocalService {
  CacheLocalService(this._box);

  static const String boxName = 'local_content_cache';
  static const Duration dailyShlokaTtl = Duration(hours: 24);
  static const Duration guruListTtl = Duration(hours: 12);

  static const String _dailyShlokaKey = 'daily_shloka';
  static const String _guruListKey = 'guru_list';
  static const String _chapterMetadataKey = 'chapter_metadata';
  static const String _audioMappingsKey = 'audio_mappings';

  final Box<dynamic> _box;

  Future<void> persistStaticData() async {
    await _box.put(_chapterMetadataKey, _cacheEntry(AppConstants.chapters));
    await _box.put(_audioMappingsKey, _cacheEntry(_audioMappings()));
  }

  List<Map<String, dynamic>> getChapterMetadata() {
    return _readList(_chapterMetadataKey);
  }

  Map<String, String> getAudioMappings() {
    final entry = _box.get(_audioMappingsKey);
    if (entry is! Map) return _audioMappings();
    final data = entry['data'];
    if (data is! Map) return _audioMappings();
    return data.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  List<Map<String, dynamic>>? getChapter(int chapter) {
    final list = _readList(_chapterKey(chapter));
    return list.isEmpty ? null : list;
  }

  Future<void> saveChapter(int chapter, List<Map<String, dynamic>> shlokas) {
    return _box.put(_chapterKey(chapter), _cacheEntry(shlokas));
  }

  Map<String, dynamic>? getDailyShloka({bool allowExpired = false}) {
    return _readMap(
      _dailyShlokaKey,
      ttl: dailyShlokaTtl,
      allowExpired: allowExpired,
    );
  }

  Future<void> saveDailyShloka(Map<String, dynamic> shloka) {
    return _box.put(_dailyShlokaKey, _cacheEntry(shloka));
  }

  List<Map<String, dynamic>>? getGuruList({bool allowExpired = false}) {
    final list = _readList(
      _guruListKey,
      ttl: guruListTtl,
      allowExpired: allowExpired,
    );
    return list.isEmpty ? null : list;
  }

  Future<void> saveGuruList(List<Map<String, dynamic>> gurus) {
    return _box.put(_guruListKey, _cacheEntry(gurus));
  }

  Map<String, dynamic>? _readMap(
    String key, {
    Duration? ttl,
    bool allowExpired = false,
  }) {
    final entry = _box.get(key);
    if (!_isUsable(entry, ttl: ttl, allowExpired: allowExpired)) return null;
    final data = (entry as Map)['data'];
    if (data is! Map) return null;
    return Map<String, dynamic>.from(data);
  }

  List<Map<String, dynamic>> _readList(
    String key, {
    Duration? ttl,
    bool allowExpired = false,
  }) {
    final entry = _box.get(key);
    if (!_isUsable(entry, ttl: ttl, allowExpired: allowExpired)) return [];
    final data = (entry as Map)['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  bool _isUsable(
    dynamic entry, {
    Duration? ttl,
    required bool allowExpired,
  }) {
    if (entry is! Map) return false;
    if (ttl == null || allowExpired) return true;
    final cachedAt = _dateFromValue(entry['cachedAt']);
    if (cachedAt == null) return false;
    return DateTime.now().difference(cachedAt) < ttl;
  }

  Map<String, dynamic> _cacheEntry(dynamic data) {
    return {
      'cachedAt': DateTime.now().toIso8601String(),
      'data': data,
    };
  }

  String _chapterKey(int chapter) => 'chapter_$chapter';

  Map<String, String> _audioMappings() {
    return {
      for (var chapter = 1; chapter <= 15; chapter++)
        '$chapter':
            '${chapter.toString().padLeft(2, '0')}-Track${chapter.toString().padLeft(2, '0')}.mp3',
    };
  }

  DateTime? _dateFromValue(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
