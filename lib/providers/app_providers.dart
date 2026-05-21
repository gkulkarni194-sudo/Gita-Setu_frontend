import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../local/cache_local_service.dart';
import '../repositories/ai_repository.dart';
import '../repositories/gita_repository.dart';
import '../repositories/guru_repository.dart';
import '../repositories/api_service.dart';
export 'admin_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final cacheLocalServiceProvider = Provider<CacheLocalService>((ref) {
  return CacheLocalService(Hive.box<dynamic>(CacheLocalService.boxName));
});

final gitaRepositoryProvider = Provider<GitaRepository>((ref) {
  return GitaRepository(
    ref.watch(apiServiceProvider),
    ref.watch(cacheLocalServiceProvider),
  );
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(ref.watch(apiServiceProvider));
});

final guruRepositoryProvider = Provider<GuruRepository>((ref) {
  return GuruRepository(
    ref.watch(apiServiceProvider),
    ref.watch(cacheLocalServiceProvider),
  );
});

final dailyShlokaProvider = FutureProvider((ref) {
  return ref.watch(gitaRepositoryProvider).getDailyShloka();
});

final chapterShlokasProvider = FutureProvider.family((ref, int chapter) {
  return ref.watch(gitaRepositoryProvider).getChapterShlokas(chapter);
});

final gurusProvider = FutureProvider((ref) {
  return ref.watch(guruRepositoryProvider).getGurus();
});


