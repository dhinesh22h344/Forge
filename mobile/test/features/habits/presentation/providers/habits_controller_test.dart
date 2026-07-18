import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/error/failure.dart';
import 'package:forge/core/error/result.dart';
import 'package:forge/core/offline/offline_queue.dart';
import 'package:forge/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:forge/features/habits/domain/entities/habit.dart';
import 'package:forge/features/habits/domain/entities/habit_log.dart';
import 'package:forge/features/habits/domain/entities/habit_reminder.dart';
import 'package:forge/features/habits/domain/entities/repeat_type.dart';
import 'package:forge/features/habits/domain/repositories/habit_repository.dart';
import 'package:forge/features/habits/presentation/providers/habits_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Habit _buildHabit(String id) => Habit(
      id: id,
      categoryId: 'cat-1',
      name: 'Read',
      priority: 2,
      difficulty: 3,
      repeatType: RepeatType.daily,
      repeatConfig: const {},
      color: '#6C5CE7',
      startDate: DateTime(2026, 1, 1),
      tags: const [],
      status: 'ACTIVE',
      archived: false,
    );

/// Hand-rolled rather than mocktail — `upsertLog`'s `logDate` argument is
/// `DateTime.now()` computed inside the controller, so exact-value argument
/// matchers don't apply cleanly; a fake sidesteps that entirely.
class _FakeHabitRepository implements HabitRepository {
  _FakeHabitRepository({required this.habit, this.upsertResult});

  final Habit habit;
  Result<HabitLog>? upsertResult;
  final List<HabitLogStatus> upsertedStatuses = [];

  @override
  Future<Result<List<Habit>>> list({String? categoryId, bool? archived}) async => Success([habit]);

  @override
  Future<Result<List<HabitLog>>> logs(String habitId) async => const Success([]);

  @override
  Future<Result<HabitLog>> upsertLog({
    required String habitId,
    required DateTime logDate,
    required HabitLogStatus status,
    double? progressValue,
    String? notes,
  }) async {
    upsertedStatuses.add(status);
    return upsertResult ??
        Success(HabitLog(id: 'log-1', habitId: habitId, logDate: logDate, status: status));
  }

  @override
  Future<Result<Habit>> create(HabitDraft draft) => throw UnimplementedError();
  @override
  Future<Result<Habit>> update(String id, HabitDraft draft) => throw UnimplementedError();
  @override
  Future<Result<void>> archive(String id, {required bool archived}) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(String id) => throw UnimplementedError();
  @override
  Future<Result<HabitStreak>> streak(String habitId) => throw UnimplementedError();
  @override
  Future<Result<List<HabitReminder>>> listReminders(String habitId) => throw UnimplementedError();
  @override
  Future<Result<HabitReminder>> createReminder(String habitId, HabitReminderDraft draft) => throw UnimplementedError();
  @override
  Future<Result<HabitReminder>> updateReminder(String habitId, String reminderId, HabitReminderDraft draft) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> deleteReminder(String habitId, String reminderId) => throw UnimplementedError();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('toggleToday applies optimistically and queues the log when offline', () async {
    final habit = _buildHabit('h1');
    final repository = _FakeHabitRepository(habit: habit, upsertResult: const Error(NetworkFailure()));
    final container = ProviderContainer(overrides: [
      habitRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    await container.read(habitsControllerProvider.future);

    final failure = await container.read(habitsControllerProvider.notifier).toggleToday(habit.id);

    expect(failure, isNull, reason: 'a connectivity failure should be queued, not surfaced as an error');
    final state = container.read(habitsControllerProvider).value!;
    expect(state.todayStatusByHabitId[habit.id], HabitLogStatus.completed);

    final pending = await container.read(offlineQueueProvider).readAll();
    expect(pending, hasLength(1));
    expect(pending.single.habitId, habit.id);
    expect(pending.single.status, 'COMPLETED');
  });

  test('toggleToday reverts the optimistic update on a real server error', () async {
    final habit = _buildHabit('h1');
    final repository = _FakeHabitRepository(
      habit: habit,
      upsertResult: const Error(ValidationFailure('nope')),
    );
    final container = ProviderContainer(overrides: [
      habitRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    await container.read(habitsControllerProvider.future);

    final failure = await container.read(habitsControllerProvider.notifier).toggleToday(habit.id);

    expect(failure, isA<ValidationFailure>());
    final state = container.read(habitsControllerProvider).value!;
    expect(state.todayStatusByHabitId[habit.id], isNot(HabitLogStatus.completed));

    final pending = await container.read(offlineQueueProvider).readAll();
    expect(pending, isEmpty, reason: 'a real server error should not be queued for replay');
  });

  test('toggleToday succeeds normally when online', () async {
    final habit = _buildHabit('h1');
    final repository = _FakeHabitRepository(habit: habit);
    final container = ProviderContainer(overrides: [
      habitRepositoryProvider.overrideWithValue(repository),
    ]);
    addTearDown(container.dispose);

    await container.read(habitsControllerProvider.future);

    final failure = await container.read(habitsControllerProvider.notifier).toggleToday(habit.id);

    expect(failure, isNull);
    expect(repository.upsertedStatuses, [HabitLogStatus.completed]);
    final pending = await container.read(offlineQueueProvider).readAll();
    expect(pending, isEmpty);
  });
}
