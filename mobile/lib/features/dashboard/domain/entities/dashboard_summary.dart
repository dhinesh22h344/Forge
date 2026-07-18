class DashboardSummary {
  const DashboardSummary({
    required this.currentStreak,
    required this.bestStreak,
    required this.todayCompleted,
    required this.todayTotal,
    required this.xp,
    required this.level,
    required this.weeklyCompletionRates,
    required this.recentActivity,
    required this.upcomingReminders,
    required this.dailyGoal,
  });

  final int currentStreak;
  final int bestStreak;
  final int todayCompleted;
  final int todayTotal;
  final int xp;
  final int level;

  /// One completion rate (0.0–1.0) per day, oldest first, always length 7.
  final List<double> weeklyCompletionRates;

  final List<RecentActivityItem> recentActivity;
  final List<UpcomingReminderItem> upcomingReminders;
  final DailyGoal? dailyGoal;

  bool get isEmpty => todayTotal == 0 && recentActivity.isEmpty && upcomingReminders.isEmpty;

  static const empty = DashboardSummary(
    currentStreak: 0,
    bestStreak: 0,
    todayCompleted: 0,
    todayTotal: 0,
    xp: 0,
    level: 1,
    weeklyCompletionRates: [0, 0, 0, 0, 0, 0, 0],
    recentActivity: [],
    upcomingReminders: [],
    dailyGoal: null,
  );
}

class RecentActivityItem {
  const RecentActivityItem({required this.habitName, required this.completedAt, required this.icon});
  final String habitName;
  final DateTime completedAt;
  final String icon;
}

class UpcomingReminderItem {
  const UpcomingReminderItem({required this.habitName, required this.scheduledAt});
  final String habitName;
  final DateTime scheduledAt;
}

class DailyGoal {
  const DailyGoal({required this.completed, required this.target});
  final int completed;
  final int target;
}
