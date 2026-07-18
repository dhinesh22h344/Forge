import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel {
  static DashboardSummary fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      todayCompleted: json['todayCompleted'] as int? ?? 0,
      todayTotal: json['todayTotal'] as int? ?? 0,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      weeklyCompletionRates: (json['weeklyCompletionRates'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [0, 0, 0, 0, 0, 0, 0],
      recentActivity: (json['recentActivity'] as List? ?? [])
          .map((e) => RecentActivityItem(
                habitName: e['habitName'] as String,
                completedAt: DateTime.parse(e['completedAt'] as String),
                icon: e['icon'] as String? ?? 'check_circle',
              ))
          .toList(),
      upcomingReminders: (json['upcomingReminders'] as List? ?? [])
          .map((e) => UpcomingReminderItem(
                habitName: e['habitName'] as String,
                scheduledAt: DateTime.parse(e['scheduledAt'] as String),
              ))
          .toList(),
      dailyGoal: json['dailyGoal'] == null
          ? null
          : DailyGoal(
              completed: json['dailyGoal']['completed'] as int,
              target: json['dailyGoal']['target'] as int,
            ),
    );
  }
}
