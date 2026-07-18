class HabitRecord {
  const HabitRecord({
    required this.habitId,
    required this.habitName,
    required this.habitColor,
    this.habitIcon,
    this.habitEmoji,
    required this.bestStreak,
    required this.totalCompletions,
  });

  final String habitId;
  final String habitName;
  final String habitColor;
  final String? habitIcon;
  final String? habitEmoji;
  final int bestStreak;
  final int totalCompletions;
}

/// All-time bests — deliberately unbounded, unlike ReportOverview which caps
/// lookback at 365 days for the Reports screen's own cost reasons.
class PersonalRecords {
  const PersonalRecords({
    required this.totalCompletionsAllTime,
    required this.bestStreakEver,
    this.bestStreakHabitId,
    this.bestStreakHabitName,
    required this.bestPerfectDayStreakEver,
    this.bestSingleDayDate,
    required this.bestSingleDayCompletions,
    required this.perHabitRecords,
  });

  final int totalCompletionsAllTime;
  final int bestStreakEver;
  final String? bestStreakHabitId;
  final String? bestStreakHabitName;
  final int bestPerfectDayStreakEver;
  final DateTime? bestSingleDayDate;
  final int bestSingleDayCompletions;
  final List<HabitRecord> perHabitRecords;
}
