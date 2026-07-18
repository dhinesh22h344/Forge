import '../../../../core/error/result.dart';
import '../entities/habit.dart';
import '../entities/habit_log.dart';
import '../entities/repeat_type.dart';

abstract class HabitRepository {
  Future<Result<List<Habit>>> list({String? categoryId, bool? archived});

  Future<Result<Habit>> create(HabitDraft draft);

  Future<Result<Habit>> update(String id, HabitDraft draft);

  Future<Result<void>> archive(String id, {required bool archived});

  Future<Result<void>> delete(String id);

  Future<Result<List<HabitLog>>> logs(String habitId);

  Future<Result<HabitLog>> upsertLog({
    required String habitId,
    required DateTime logDate,
    required HabitLogStatus status,
    double? progressValue,
    String? notes,
  });

  Future<Result<HabitStreak>> streak(String habitId);
}

/// The full set of fields needed to create or update a habit — kept as one
/// value object so create/update use cases and the multi-field form don't
/// have to pass 16 positional/named parameters around individually.
class HabitDraft {
  const HabitDraft({
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
  });

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
}
