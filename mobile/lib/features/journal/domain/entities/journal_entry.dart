enum JournalMood { great, good, okay, low, rough }

extension JournalMoodWire on JournalMood {
  String get wireValue => name.toUpperCase();

  static JournalMood? fromWire(String? value) {
    if (value == null) return null;
    return JournalMood.values.where((m) => m.wireValue == value).firstOrNull;
  }

  String get emoji => switch (this) {
        JournalMood.great => '🤩',
        JournalMood.good => '🙂',
        JournalMood.okay => '😐',
        JournalMood.low => '😕',
        JournalMood.rough => '😣',
      };

  String get label => switch (this) {
        JournalMood.great => 'Great',
        JournalMood.good => 'Good',
        JournalMood.okay => 'Okay',
        JournalMood.low => 'Low',
        JournalMood.rough => 'Rough',
      };
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.entryDate,
    required this.content,
    this.mood,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DateTime entryDate;
  final String content;
  final JournalMood? mood;
  final DateTime createdAt;
  final DateTime updatedAt;
}
