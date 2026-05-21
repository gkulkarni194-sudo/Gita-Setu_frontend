import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../local/journal_local_service.dart';
import '../models/journal_entry.dart';
import '../repositories/journal_repository.dart';
import 'app_providers.dart';

final journalLocalServiceProvider = Provider<JournalLocalService>((ref) {
  return JournalLocalService(
      Hive.box<JournalEntry>(JournalLocalService.boxName));
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(
    localService: ref.watch(journalLocalServiceProvider),
    apiService: ref.watch(apiServiceProvider),
  );
});

final journalEntriesProvider =
    StateNotifierProvider<JournalEntriesNotifier, List<JournalEntry>>((ref) {
  return JournalEntriesNotifier(ref.watch(journalRepositoryProvider));
});

class JournalEntriesNotifier extends StateNotifier<List<JournalEntry>> {
  JournalEntriesNotifier(this._repository) : super(_repository.entries());

  final JournalRepository _repository;

  void refresh({String query = ''}) {
    state = _repository.entries(query: query);
  }

  Future<JournalEntry> create({String? title, required String content}) async {
    final entry = await _repository.create(title: title, content: content);
    refresh();
    return entry;
  }

  Future<JournalEntry> update(JournalEntry entry,
      {String? title, required String content}) async {
    final updated =
        await _repository.update(entry, title: title, content: content);
    refresh();
    return updated;
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    refresh();
  }

  Future<void> clear() async {
    await _repository.clear();
    refresh();
  }
}
