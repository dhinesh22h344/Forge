import '../../domain/entities/furnace_ember.dart';

class FurnaceEmberModel extends FurnaceEmber {
  const FurnaceEmberModel({
    required super.habitId,
    required super.habitName,
    required super.habitColor,
    super.habitIcon,
    super.habitEmoji,
    required super.missedDate,
    required super.graceDeadline,
    required super.recoverable,
    super.cooldownEndsAt,
  });

  factory FurnaceEmberModel.fromJson(Map<String, dynamic> json) {
    return FurnaceEmberModel(
      habitId: json['habitId'] as String,
      habitName: json['habitName'] as String,
      habitColor: json['habitColor'] as String,
      habitIcon: json['habitIcon'] as String?,
      habitEmoji: json['habitEmoji'] as String?,
      missedDate: DateTime.parse(json['missedDate'] as String),
      graceDeadline: DateTime.parse(json['graceDeadline'] as String),
      recoverable: json['recoverable'] as bool,
      cooldownEndsAt: json['cooldownEndsAt'] == null ? null : DateTime.parse(json['cooldownEndsAt'] as String),
    );
  }
}

class FurnaceReforgeResultModel extends FurnaceReforgeResult {
  const FurnaceReforgeResultModel({
    required super.habitId,
    required super.recoveredDate,
    required super.currentStreak,
    required super.bestStreak,
  });

  factory FurnaceReforgeResultModel.fromJson(Map<String, dynamic> json) {
    return FurnaceReforgeResultModel(
      habitId: json['habitId'] as String,
      recoveredDate: DateTime.parse(json['recoveredDate'] as String),
      currentStreak: json['currentStreak'] as int,
      bestStreak: json['bestStreak'] as int,
    );
  }
}
