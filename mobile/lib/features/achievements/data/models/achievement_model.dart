import '../../domain/entities/achievement.dart';

class AchievementModel extends Achievement {
  const AchievementModel({
    required super.code,
    required super.title,
    required super.description,
    required super.icon,
    required super.hidden,
    required super.unlocked,
    super.unlockedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      hidden: json['hidden'] as bool,
      unlocked: json['unlocked'] as bool,
      unlockedAt: json['unlockedAt'] == null ? null : DateTime.parse(json['unlockedAt'] as String),
    );
  }
}
