import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/offline/offline_queue.dart';
import '../../../../core/offline/pending_habit_log.dart';
import '../../../dashboard/presentation/providers/dashboard_controller.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/repositories/habit_repository.dart';

class HabitsState {
  const HabitsState({required this.habits, required this.todayStatusByHabitId});

  final List<Habit> habits;
  final Map<String, HabitLogStatus?> todayStatusByHabitId;

  HabitsState copyWith({List<Habit>? habits, Map<String, HabitLogStatus?>? todayStatusByHabitId}) {
    return HabitsState(
      habits: habits ?? this.habits,
      todayStatusByHabitId: todayStatusByHabitId ?? this.todayStatusByHabitId,
    );
  }
}

/// Loads the active habit list plus each habit's completion status for
/// today (so list checkboxes render correctly on open). This is N+1 requests
/// under the hood — acceptable for the handful of habits a personal-use app
/// has open at once; revisit with a bulk "today status" endpoint if habit
/// counts grow large enough to matter.
class HabitsController extends AsyncNotifier<HabitsState> {
  @override
  Future<HabitsState> build() async {
    final repository = ref.watch(habitRepositoryProvider);
    final habitsResult = await repository.list(archived: false);
    final habits = habitsResult.when(success: (h) => h, failure: (_) => const <Habit>[]);

    final today = DateTime.now();
    final statusEntries = await Future.wait(habits.map((habit) async {
      final logsResult = await repository.logs(habit.id);
      final logs = logsResult.when(success: (l) => l, failure: (_) => const <HabitLog>[]);
      final todayLogs = logs.where((l) => _isSameDay(l.logDate, today));
      final todayLog = todayLogs.isEmpty ? null : todayLogs.first;
      return MapEntry(habit.id, todayLog?.status);
    }));

    return HabitsState(habits: habits, todayStatusByHabitId: Map.fromEntries(statusEntries));
  }

  Future<Failure?> createHabit(HabitDraft draft) async {
    final repository = ref.read(habitRepositoryProvider);
    final result = await repository.create(draft);
    return result.when(
      success: (habit) {
        final current = state.value;
        if (current != null) {
          state = AsyncData(current.copyWith(habits: [...current.habits, habit]));
        }
        ref.invalidate(dashboardControllerProvider);
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<Failure?> updateHabit(String id, HabitDraft draft) async {
    final repository = ref.read(habitRepositoryProvider);
    final result = await repository.update(id, draft);
    return result.when(
      success: (updated) {
        final current = state.value;
        if (current != null) {
          state = AsyncData(current.copyWith(habits: [for (final h in current.habits) if (h.id == id) updated else h]));
        }
        return null;
      },
      failure: (failure) => failure,
    );
  }

  Future<Failure?> archiveHabit(String id) async {
    final repository = ref.read(habitRepositoryProvider);
    final result = await repository.archive(id, archived: true);
    return result.when(
      success: (_) async {
        final current = state.value;
        if (current != null) {
          state = AsyncData(current.copyWith(habits: [for (final h in current.habits) if (h.id != id) h]));
        }
        ref.invalidate(dashboardControllerProvider);
        // Archived habits stop repeating, so any pending reminder
        // notifications for them would otherwise fire for nothing.
        final remindersResult = await repository.listReminders(id);
        remindersResult.when(
          success: (reminders) => NotificationService.instance.cancelAllForReminders(reminders.map((r) => r.id)),
          failure: (_) => null,
        );
        return null;
      },
      failure: (failure) async => failure,
    );
  }

  /// Toggles today's completion. Tapping an incomplete habit marks it
  /// COMPLETED; tapping a completed one marks it SKIPPED — there's no
  /// dedicated "clear today's log" endpoint, so SKIPPED stands in for "not
  /// doing this today" and correctly reverses the XP grant server-side.
  ///
  /// Offline-first: the toggle applies to local state immediately regardless
  /// of connectivity. If the request can't reach the server at all, it's
  /// queued (see `OfflineQueue`) and replayed on reconnect instead of being
  /// surfaced as an error — a real server error (validation etc.) still
  /// reverts the optimistic update and returns the failure.
  Future<Failure?> toggleToday(String habitId) async {
    final current = state.value;
    if (current == null) return null;
    final wasCompleted = current.todayStatusByHabitId[habitId] == HabitLogStatus.completed;
    final newStatus = wasCompleted ? HabitLogStatus.skipped : HabitLogStatus.completed;
    final today = DateTime.now();

    state = AsyncData(current.copyWith(
      todayStatusByHabitId: {...current.todayStatusByHabitId, habitId: newStatus},
    ));
    // Streak/XP/today's-progress on the dashboard are derived from this same
    // log — without this it stays stale until the app restarts, since
    // StatefulShellRoute keeps DashboardScreen alive off-screen rather than
    // rebuilding it on tab switch.
    ref.invalidate(dashboardControllerProvider);

    final repository = ref.read(habitRepositoryProvider);
    final result = await repository.upsertLog(habitId: habitId, logDate: today, status: newStatus);
    return result.when(
      success: (_) async => null,
      failure: (failure) async {
        if (failure is NetworkFailure) {
          await ref.read(offlineQueueProvider).upsert(PendingHabitLog(
                habitId: habitId,
                logDate: _dateOnly(today),
                status: newStatus.wireValue,
              ));
          return null;
        }
        // Not a connectivity issue — the optimistic update was wrong, revert it.
        final latest = state.value ?? current;
        state = AsyncData(latest.copyWith(
          todayStatusByHabitId: {
            ...latest.todayStatusByHabitId,
            habitId: wasCompleted ? HabitLogStatus.completed : HabitLogStatus.skipped,
          },
        ));
        return failure;
      },
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String _dateOnly(DateTime d) => d.toIso8601String().split('T').first;

final habitsControllerProvider = AsyncNotifierProvider<HabitsController, HabitsState>(HabitsController.new);
