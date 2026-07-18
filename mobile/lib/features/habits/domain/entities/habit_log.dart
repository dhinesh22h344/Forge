enum HabitLogStatus {
  completed,
  missed,
  skipped;

  String get wireValue {
    switch (this) {
      case HabitLogStatus.completed:
        return 'COMPLETED';
      case HabitLogStatus.missed:
        return 'MISSED';
      case HabitLogStatus.skipped:
        return 'SKIPPED';
    }
  }

  static HabitLogStatus fromWireValue(String value) {
    return HabitLogStatus.values.firstWhere((s) => s.wireValue == value, orElse: () => HabitLogStatus.skipped);
  }
}

class HabitLog {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.logDate,
    required this.status,
    this.progressValue,
    this.notes,
    this.completedAt,
  });

  final String id;
  final String habitId;
  final DateTime logDate;
  final HabitLogStatus status;
  final double? progressValue;
  final String? notes;
  final DateTime? completedAt;
}

class HabitStreak {
  const HabitStreak({required this.currentStreak, required this.bestStreak});
  final int currentStreak;
  final int bestStreak;
}
