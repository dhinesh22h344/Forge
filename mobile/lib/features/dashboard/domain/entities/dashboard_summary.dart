import 'dart:math' as math;

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

  bool get isEmpty =>
      todayTotal == 0 && recentActivity.isEmpty && upcomingReminders.isEmpty;

  /// Cross-category consistency, 0.0-1.0 — the single number the Forge Flame
  /// visual represents. `todayCompleted`/`todayTotal` already spans every
  /// category (it's a dashboard-level aggregate, not scoped to one), so this
  /// stays cross-category by construction rather than averaging per category.
  /// Weighted toward "did you show up today" (60%) with the streak as a
  /// slower-moving anchor (40%) so one missed day doesn't snuff a long
  /// streak's glow, and floored above zero so the flame is always an ember,
  /// never fully out.
  double get consistencyScore {
    final todayRatio = todayTotal == 0
        ? null
        : (todayCompleted / todayTotal).clamp(0.0, 1.0);
    final streakFactor = (currentStreak / 14).clamp(0.0, 1.0);
    final score = todayRatio == null
        ? streakFactor
        : (todayRatio * 0.6 + streakFactor * 0.4);
    return math.max(score, 0.08);
  }

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
  const RecentActivityItem({
    required this.habitName,
    required this.completedAt,
    required this.icon,
  });
  final String habitName;
  final DateTime completedAt;
  final String icon;
}

class UpcomingReminderItem {
  const UpcomingReminderItem({
    required this.habitName,
    required this.scheduledAt,
  });
  final String habitName;
  final DateTime scheduledAt;
}

class DailyGoal {
  const DailyGoal({required this.completed, required this.target});
  final int completed;
  final int target;
}
