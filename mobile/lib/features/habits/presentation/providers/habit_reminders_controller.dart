import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_reminder.dart';
import '../../domain/repositories/habit_repository.dart';

/// One instance per habit id — reminders are always viewed/edited in the
/// context of a single habit's detail screen.
class HabitRemindersController extends FamilyAsyncNotifier<List<HabitReminder>, String> {
  @override
  Future<List<HabitReminder>> build(String habitId) async {
    final repository = ref.watch(habitRepositoryProvider);
    final result = await repository.listReminders(habitId);
    return result.when(success: (r) => r, failure: (_) => const []);
  }

  Future<Failure?> addReminder(Habit habit, HabitReminderDraft draft) async {
    final repository = ref.read(habitRepositoryProvider);
    final result = await repository.createReminder(habit.id, draft);
    return result.when(
      success: (reminder) async {
        state = AsyncData([...(state.value ?? []), reminder]);
        await NotificationService.instance.scheduleReminder(habit, reminder);
        return null;
      },
      failure: (f) async => f,
    );
  }

  Future<Failure?> updateReminder(Habit habit, String reminderId, HabitReminderDraft draft) async {
    final repository = ref.read(habitRepositoryProvider);
    final result = await repository.updateReminder(habit.id, reminderId, draft);
    return result.when(
      success: (reminder) async {
        final current = state.value ?? [];
        state = AsyncData([for (final r in current) if (r.id == reminderId) reminder else r]);
        await NotificationService.instance.scheduleReminder(habit, reminder);
        return null;
      },
      failure: (f) async => f,
    );
  }

  /// Flips `active` only — a dedicated method so the switch in the UI reads
  /// as one clear action rather than the caller assembling a full draft.
  Future<Failure?> toggleActive(Habit habit, HabitReminder reminder) {
    return updateReminder(
      habit,
      reminder.id,
      HabitReminderDraft(
        hour: reminder.hour,
        minute: reminder.minute,
        daysOfWeek: reminder.daysOfWeek,
        active: !reminder.active,
      ),
    );
  }

  Future<Failure?> deleteReminder(String habitId, String reminderId) async {
    final repository = ref.read(habitRepositoryProvider);
    final result = await repository.deleteReminder(habitId, reminderId);
    return result.when(
      success: (_) async {
        state = AsyncData([for (final r in state.value ?? []) if (r.id != reminderId) r]);
        await NotificationService.instance.cancelReminder(reminderId);
        return null;
      },
      failure: (f) async => f,
    );
  }
}

final habitRemindersControllerProvider =
    AsyncNotifierProviderFamily<HabitRemindersController, List<HabitReminder>, String>(
  HabitRemindersController.new,
);
