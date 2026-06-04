import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 1)
class JournalEntry extends HiveObject {
  JournalEntry({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.title,
  });

  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String? title;
  
  @HiveField(2)
  final String content;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final DateTime updatedAt;

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
