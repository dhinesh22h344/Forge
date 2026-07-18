import '../../domain/entities/habit_reminder.dart';
import '../../domain/repositories/habit_repository.dart';

class HabitReminderModel extends HabitReminder {
  const HabitReminderModel({
    required super.id,
    required super.habitId,
    required super.hour,
    required super.minute,
    required super.daysOfWeek,
    required super.active,
  });

  /// `HabitReminderResponse` on the backend has no `habitId` field (it's
  /// implicit in the URL path), so the caller supplies it.
  factory HabitReminderModel.fromJson(Map<String, dynamic> json, {required String habitId}) {
    final parts = (json['localTime'] as String).split(':');
    return HabitReminderModel(
      id: json['id'] as String,
      habitId: habitId,
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
      daysOfWeek: (json['daysOfWeek'] as List?)?.cast<String>() ?? const [],
      active: json['active'] as bool,
    );
  }

  static Map<String, dynamic> draftToJson(HabitReminderDraft draft) {
    String two(int n) => n.toString().padLeft(2, '0');
    return {
      'localTime': '${two(draft.hour)}:${two(draft.minute)}:00',
      'daysOfWeek': draft.daysOfWeek,
      'active': draft.active,
    };
  }
}
