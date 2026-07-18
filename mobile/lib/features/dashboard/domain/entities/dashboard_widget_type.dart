enum DashboardWidgetType {
  currentStreak,
  bestStreak,
  todayProgress,
  weeklyProgress,
  xpLevel,
  quickAdd,
  recentActivity,
  upcomingReminders,
  calendarPreview,
  motivationalQuote,
  dailyGoal;

  String get label {
    switch (this) {
      case DashboardWidgetType.currentStreak:
        return 'Current Streak';
      case DashboardWidgetType.bestStreak:
        return 'Best Streak';
      case DashboardWidgetType.todayProgress:
        return "Today's Progress";
      case DashboardWidgetType.weeklyProgress:
        return 'Weekly Progress';
      case DashboardWidgetType.xpLevel:
        return 'XP & Level';
      case DashboardWidgetType.quickAdd:
        return 'Quick Add Habit';
      case DashboardWidgetType.recentActivity:
        return 'Recent Activity';
      case DashboardWidgetType.upcomingReminders:
        return 'Upcoming Reminders';
      case DashboardWidgetType.calendarPreview:
        return 'Calendar Preview';
      case DashboardWidgetType.motivationalQuote:
        return 'Motivational Quote';
      case DashboardWidgetType.dailyGoal:
        return 'Daily Goal';
    }
  }
}
