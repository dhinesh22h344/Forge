import '../../domain/entities/habit_log.dart';

class HabitLogModel extends HabitLog {
  const HabitLogModel({
    required super.id,
    required super.habitId,
    required super.logDate,
    required super.status,
    super.progressValue,
    super.notes,
    super.completedAt,
  });

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      logDate: DateTime.parse(json['logDate'] as String),
      status: HabitLogStatus.fromWireValue(json['status'] as String),
      progressValue: (json['progressValue'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
    );
  }
}

class HabitStreakModel extends HabitStreak {
  const HabitStreakModel({required super.currentStreak, required super.bestStreak});

  factory HabitStreakModel.fromJson(Map<String, dynamic> json) {
    return HabitStreakModel(currentStreak: json['currentStreak'] as int, bestStreak: json['bestStreak'] as int);
  }
}
