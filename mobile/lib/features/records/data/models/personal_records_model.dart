import '../../domain/entities/personal_records.dart';

class HabitRecordModel extends HabitRecord {
  const HabitRecordModel({
    required super.habitId,
    required super.habitName,
    required super.habitColor,
    super.habitIcon,
    super.habitEmoji,
    required super.bestStreak,
    required super.totalCompletions,
  });

  factory HabitRecordModel.fromJson(Map<String, dynamic> json) {
    return HabitRecordModel(
      habitId: json['habitId'] as String,
      habitName: json['habitName'] as String,
      habitColor: json['habitColor'] as String,
      habitIcon: json['habitIcon'] as String?,
      habitEmoji: json['habitEmoji'] as String?,
      bestStreak: json['bestStreak'] as int,
      totalCompletions: (json['totalCompletions'] as num).toInt(),
    );
  }
}

class PersonalRecordsModel extends PersonalRecords {
  const PersonalRecordsModel({
    required super.totalCompletionsAllTime,
    required super.bestStreakEver,
    super.bestStreakHabitId,
    super.bestStreakHabitName,
    required super.bestPerfectDayStreakEver,
    super.bestSingleDayDate,
    required super.bestSingleDayCompletions,
    required super.perHabitRecords,
  });

  factory PersonalRecordsModel.fromJson(Map<String, dynamic> json) {
    return PersonalRecordsModel(
      totalCompletionsAllTime: (json['totalCompletionsAllTime'] as num).toInt(),
      bestStreakEver: json['bestStreakEver'] as int,
      bestStreakHabitId: json['bestStreakHabitId'] as String?,
      bestStreakHabitName: json['bestStreakHabitName'] as String?,
      bestPerfectDayStreakEver: json['bestPerfectDayStreakEver'] as int,
      bestSingleDayDate: json['bestSingleDayDate'] == null ? null : DateTime.parse(json['bestSingleDayDate'] as String),
      bestSingleDayCompletions: json['bestSingleDayCompletions'] as int,
      perHabitRecords: (json['perHabitRecords'] as List)
          .map((e) => HabitRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
