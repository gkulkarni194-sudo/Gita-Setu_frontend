import 'package:hive_flutter/hive_flutter.dart';

import '../models/journal_entry.dart';

class JournalLocalService {
  JournalLocalService(this._box);

  static const String boxName = 'journal_entries';

  final Box<JournalEntry> _box;

  List<JournalEntry> getAll() {
    final entries = _box.values.toList();
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entries;
  }

  List<JournalEntry> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return getAll();

    return getAll()
        .where(
          (entry) =>
              (entry.title ?? '').toLowerCase().contains(normalized) ||
              entry.content.toLowerCase().contains(normalized),
        )
        .toList();
  }

  Future<void> save(JournalEntry entry) {
    return _box.put(entry.id, entry);
  }

  Future<void> delete(String id) {
    return _box.delete(id);
  }

  Future<void> clear() {
    return _box.clear();
  }

  Stream<BoxEvent> watch() => _box.watch();
}
