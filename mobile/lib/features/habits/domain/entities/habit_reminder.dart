/// A single reminder attached to a habit. A habit can have several,
/// independently toggleable (spec: "Multiple Reminders").
class HabitReminder {
  const HabitReminder({
    required this.id,
    required this.habitId,
    required this.hour,
    required this.minute,
    required this.daysOfWeek,
    required this.active,
  });

  final String id;
  final String habitId;
  final int hour;
  final int minute;

  /// 3-letter codes, e.g. `["MON","WED","FRI"]`. Empty means every day this
  /// habit repeats.
  final List<String> daysOfWeek;
  final bool active;
}
