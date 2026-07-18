import '../../domain/entities/category_performance.dart';
import '../../domain/entities/heatmap_day.dart';
import '../../domain/entities/report_overview.dart';
import '../../domain/entities/weekday_stat.dart';

class ReportOverviewModel extends ReportOverview {
  const ReportOverviewModel({
    required super.totalCompletions,
    required super.totalMissed,
    required super.completionRate,
    required super.currentStreak,
    required super.bestStreak,
    required super.xpEarned,
    required super.level,
    required super.activeHabitCount,
  });

  factory ReportOverviewModel.fromJson(Map<String, dynamic> json) {
    return ReportOverviewModel(
      totalCompletions: json['totalCompletions'] as int,
      totalMissed: json['totalMissed'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
      currentStreak: json['currentStreak'] as int,
      bestStreak: json['bestStreak'] as int,
      xpEarned: json['xpEarned'] as int,
      level: json['level'] as int,
      activeHabitCount: json['activeHabitCount'] as int,
    );
  }
}

class HeatmapDayModel extends HeatmapDay {
  const HeatmapDayModel({
    required super.date,
    required super.scheduledCount,
    required super.completedCount,
    required super.completionRate,
  });

  factory HeatmapDayModel.fromJson(Map<String, dynamic> json) {
    return HeatmapDayModel(
      date: DateTime.parse(json['date'] as String),
      scheduledCount: json['scheduledCount'] as int,
      completedCount: json['completedCount'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
    );
  }
}

class CategoryPerformanceModel extends CategoryPerformance {
  const CategoryPerformanceModel({
    required super.categoryId,
    required super.categoryName,
    required super.color,
    required super.habitCount,
    required super.totalCompletions,
    required super.totalScheduled,
    required super.completionRate,
  });

  factory CategoryPerformanceModel.fromJson(Map<String, dynamic> json) {
    return CategoryPerformanceModel(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      color: json['color'] as String,
      habitCount: json['habitCount'] as int,
      totalCompletions: json['totalCompletions'] as int,
      totalScheduled: json['totalScheduled'] as int,
      completionRate: (json['completionRate'] as num).toDouble(),
    );
  }
}

class WeekdayStatModel extends WeekdayStat {
  const WeekdayStatModel({required super.weekday, required super.completionRate});

  factory WeekdayStatModel.fromJson(Map<String, dynamic> json) {
    return WeekdayStatModel(
      weekday: json['weekday'] as String,
      completionRate: (json['completionRate'] as num).toDouble(),
    );
  }
}
