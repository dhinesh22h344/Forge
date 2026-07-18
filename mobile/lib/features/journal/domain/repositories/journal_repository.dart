import '../../../../core/error/result.dart';
import '../entities/journal_entry.dart';

abstract class JournalRepository {
  Future<Result<List<JournalEntry>>> list({DateTime? from, DateTime? to});

  Future<Result<JournalEntry>> get(DateTime date);

  Future<Result<JournalEntry>> upsert({
    required DateTime date,
    required String content,
    JournalMood? mood,
  });

  Future<Result<void>> delete(DateTime date);
}
