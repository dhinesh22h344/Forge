import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/error/failure.dart';
import 'package:forge/core/error/result.dart';
import 'package:forge/features/journal/data/repositories/journal_repository_impl.dart';
import 'package:forge/features/journal/domain/entities/journal_entry.dart';
import 'package:forge/features/journal/domain/repositories/journal_repository.dart';
import 'package:forge/features/journal/presentation/providers/journal_controller.dart';

class _FakeJournalRepository implements JournalRepository {
  _FakeJournalRepository({required this.initial, this.upsertResult});

  final List<JournalEntry> initial;
  Result<JournalEntry>? upsertResult;

  @override
  Future<Result<List<JournalEntry>>> list({DateTime? from, DateTime? to}) async => Success(initial);

  @override
  Future<Result<JournalEntry>> get(DateTime date) => throw UnimplementedError();

  @override
  Future<Result<JournalEntry>> upsert({required DateTime date, required String content, JournalMood? mood}) async {
    return upsertResult ??
        Success(JournalEntry(
          id: 'e-${date.toIso8601String()}',
          entryDate: date,
          content: content,
          mood: mood,
          createdAt: date,
          updatedAt: date,
        ));
  }

  @override
  Future<Result<void>> delete(DateTime date) async => const Success(null);
}

void main() {
  test('upsert replaces the existing entry for the same day rather than duplicating it', () async {
    final today = DateTime(2026, 7, 18);
    final existing = JournalEntry(
      id: 'e1',
      entryDate: today,
      content: 'Old content',
      mood: JournalMood.okay,
      createdAt: today,
      updatedAt: today,
    );
    final repository = _FakeJournalRepository(initial: [existing]);
    final container = ProviderContainer(overrides: [
      journalRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    await container.read(journalControllerProvider.future);

    final failure = await container
        .read(journalControllerProvider.notifier)
        .upsert(date: today, content: 'New content', mood: JournalMood.great);

    expect(failure, isNull);
    final state = container.read(journalControllerProvider).value!;
    expect(state, hasLength(1));
    expect(state.single.content, 'New content');
    expect(state.single.mood, JournalMood.great);
  });

  test('upsert surfaces a failure without mutating state', () async {
    final repository = _FakeJournalRepository(
      initial: const [],
      upsertResult: const Error(ValidationFailure('nope')),
    );
    final container = ProviderContainer(overrides: [
      journalRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    await container.read(journalControllerProvider.future);

    final failure = await container
        .read(journalControllerProvider.notifier)
        .upsert(date: DateTime(2026, 7, 18), content: 'Hi', mood: null);

    expect(failure, isA<ValidationFailure>());
    expect(container.read(journalControllerProvider).value, isEmpty);
  });

  test('delete removes the entry for that day', () async {
    final today = DateTime(2026, 7, 18);
    final existing = JournalEntry(
      id: 'e1',
      entryDate: today,
      content: 'Content',
      mood: null,
      createdAt: today,
      updatedAt: today,
    );
    final repository = _FakeJournalRepository(initial: [existing]);
    final container = ProviderContainer(overrides: [
      journalRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    await container.read(journalControllerProvider.future);
    final failure = await container.read(journalControllerProvider.notifier).delete(today);

    expect(failure, isNull);
    expect(container.read(journalControllerProvider).value, isEmpty);
  });
}
