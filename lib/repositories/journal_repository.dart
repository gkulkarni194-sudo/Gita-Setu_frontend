import '../local/journal_local_service.dart';
import '../models/journal_entry.dart';
import 'api_service.dart';
import '../models/api_response.dart';

class JournalRepository {
  JournalRepository({
    required JournalLocalService localService,
    required ApiService apiService,
  })  : _localService = localService,
        _apiService = apiService;

  final JournalLocalService _localService;
  final ApiService _apiService;

  List<JournalEntry> entries({String query = ''}) {
    return query.trim().isEmpty
        ? _localService.getAll()
        : _localService.search(query);
  }

  Future<JournalEntry> create({
    String? title,
    required String content,
  }) async {
    final now = DateTime.now();
    final entry = JournalEntry(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    await _localService.save(entry);
    return entry;
  }

  Future<JournalEntry> update(JournalEntry entry,
      {String? title, required String content}) async {
    final updated = entry.copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );
    await _localService.save(updated);
    return updated;
  }

  Future<void> delete(String id) => _localService.delete(id);

  Future<void> clear() => _localService.clear();

  Future<ApiResponse<dynamic>> requestAiReflection(String content) {
    return _apiService.analyzeJournal({'content': content});
  }
}
