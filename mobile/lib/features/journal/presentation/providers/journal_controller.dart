import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/entities/journal_entry.dart';

class JournalController extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    final repository = ref.watch(journalRepositoryProvider);
    final result = await repository.list();
    return result.when(success: (entries) => entries, failure: (_) => const []);
  }

  Future<Failure?> upsert({
    required DateTime date,
    required String content,
    JournalMood? mood,
  }) async {
    final repository = ref.read(journalRepositoryProvider);
    final result = await repository.upsert(date: date, content: content, mood: mood);
    return result.when(
      success: (entry) {
        final current = state.value ?? const <JournalEntry>[];
        state = AsyncData([
          for (final e in current)
            if (!_isSameDay(e.entryDate, date)) e,
          entry,
        ]..sort((a, b) => b.entryDate.compareTo(a.entryDate)));
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<Failure?> delete(DateTime date) async {
    final repository = ref.read(journalRepositoryProvider);
    final result = await repository.delete(date);
    return result.when(
      success: (_) {
        final current = state.value ?? const <JournalEntry>[];
        state = AsyncData([for (final e in current) if (!_isSameDay(e.entryDate, date)) e]);
        return null;
      },
      failure: (failure) => failure,
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

final journalControllerProvider = AsyncNotifierProvider<JournalController, List<JournalEntry>>(JournalController.new);
