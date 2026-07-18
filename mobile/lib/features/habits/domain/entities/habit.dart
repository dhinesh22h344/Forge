import 'repeat_type.dart';

class Habit {
  const Habit({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.icon,
    this.emoji,
    this.imageUrl,
    required this.priority,
    required this.difficulty,
    required this.repeatType,
    required this.repeatConfig,
    this.goalValue,
    this.goalUnit,
    this.estimatedTimeMinutes,
    required this.color,
    this.gradient,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.tags,
    this.folder,
    required this.status,
    required this.archived,
  });

  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final String? icon;
  final String? emoji;
  final String? imageUrl;
  final int priority;
  final int difficulty;
  final RepeatType repeatType;
  final Map<String, dynamic> repeatConfig;
  final double? goalValue;
  final String? goalUnit;
  final int? estimatedTimeMinutes;
  final String color;
  final String? gradient;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final List<String> tags;
  final String? folder;
  final String status;
  final bool archived;
}
