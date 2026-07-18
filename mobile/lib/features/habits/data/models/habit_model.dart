import '../../domain/entities/habit.dart';
import '../../domain/entities/repeat_type.dart';
import '../../domain/repositories/habit_repository.dart';

class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.categoryId,
    required super.name,
    super.description,
    super.icon,
    super.emoji,
    super.imageUrl,
    required super.priority,
    required super.difficulty,
    required super.repeatType,
    required super.repeatConfig,
    super.goalValue,
    super.goalUnit,
    super.estimatedTimeMinutes,
    required super.color,
    super.gradient,
    required super.startDate,
    super.endDate,
    super.notes,
    required super.tags,
    super.folder,
    required super.status,
    required super.archived,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      emoji: json['emoji'] as String?,
      imageUrl: json['imageUrl'] as String?,
      priority: json['priority'] as int,
      difficulty: json['difficulty'] as int,
      repeatType: RepeatType.fromWireValue(json['repeatType'] as String),
      repeatConfig: (json['repeatConfig'] as Map?)?.cast<String, dynamic>() ?? const {},
      goalValue: (json['goalValue'] as num?)?.toDouble(),
      goalUnit: json['goalUnit'] as String?,
      estimatedTimeMinutes: json['estimatedTimeMinutes'] as int?,
      color: json['color'] as String,
      gradient: json['gradient'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
      notes: json['notes'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      folder: json['folder'] as String?,
      status: json['status'] as String,
      archived: json['archived'] as bool,
    );
  }

  static Map<String, dynamic> draftToJson(HabitDraft draft) {
    String dateOnly(DateTime d) => d.toIso8601String().split('T').first;
    return {
      'categoryId': draft.categoryId,
      'name': draft.name,
      'description': draft.description,
      'icon': draft.icon,
      'emoji': draft.emoji,
      'imageUrl': draft.imageUrl,
      'priority': draft.priority,
      'difficulty': draft.difficulty,
      'repeatType': draft.repeatType.wireValue,
      'repeatConfig': draft.repeatConfig,
      'goalValue': draft.goalValue,
      'goalUnit': draft.goalUnit,
      'estimatedTimeMinutes': draft.estimatedTimeMinutes,
      'color': draft.color,
      'gradient': draft.gradient,
      'startDate': dateOnly(draft.startDate),
      'endDate': draft.endDate == null ? null : dateOnly(draft.endDate!),
      'notes': draft.notes,
      'tags': draft.tags,
      'folder': draft.folder,
    };
  }
}
