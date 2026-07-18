import '../../domain/entities/journal_entry.dart';

class JournalEntryModel extends JournalEntry {
  const JournalEntryModel({
    required super.id,
    required super.entryDate,
    required super.content,
    super.mood,
    required super.createdAt,
    required super.updatedAt,
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      entryDate: DateTime.parse(json['entryDate'] as String),
      content: json['content'] as String,
      mood: JournalMoodWire.fromWire(json['mood'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
