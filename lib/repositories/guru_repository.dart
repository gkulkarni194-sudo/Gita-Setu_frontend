import '../local/cache_local_service.dart';
import '../models/guru.dart';
import '../repositories/api_service.dart';

class GuruRepository {
  const GuruRepository(this._api, this._cache);

  final ApiService _api;
  final CacheLocalService _cache;

  static const _cacheKey = 'cached_gurus';

  Future<List<Guru>> getGurus() async {
    final res = await _api.getGurus();

    if (res.success && res.data != null) {
      final list = (res.data as List<dynamic>)
          .map((e) => Guru.fromJson(e as Map<String, dynamic>))
          .toList();
      // Persist to local cache for offline resilience.
      await _cache.saveGuruList(list.map((g) => g.toJson()).toList());
      return list;
    }

    // Network failed — attempt cache fallback.
    final cached = _cache.getGuruList(allowExpired: true);
    if (cached != null && cached.isNotEmpty) {
      return cached.map((e) => Guru.fromJson(e as Map<String, dynamic>)).toList();
    }

    throw Exception(res.error?.message ?? 'Failed to fetch gurus.');
  }

  /// [adminKey] is sourced from adminPasswordProvider — never hardcoded.
  Future<Guru> addGuru(Guru guru, {required String adminKey}) async {
    final res = await _api.addGuru(guru.toJson(), adminKey: adminKey);
    if (!res.success || res.data == null) {
      throw Exception(res.error?.message ?? 'Failed to add guru.');
    }
    return Guru.fromJson(res.data as Map<String, dynamic>);
  }
}