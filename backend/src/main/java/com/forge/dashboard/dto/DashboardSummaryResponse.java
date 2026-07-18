package com.forge.dashboard.dto;

import java.util.List;

/**
 * Every field defaults to zero/empty for a brand-new account — Forge never seeds data, so this
 * is the normal response until Milestones 4-6 (Categories/Habits/Tracking) give a user something
 * to aggregate. recentActivity/upcomingReminders/dailyGoal stay empty until those milestones
 * populate the tables this endpoint will join against.
 */
public record DashboardSummaryResponse(
        int currentStreak,
        int bestStreak,
        int todayCompleted,
        int todayTotal,
        long xp,
        int level,
        List<Double> weeklyCompletionRates,
        List<RecentActivityItem> recentActivity,
        List<UpcomingReminderItem> upcomingReminders,
        DailyGoal dailyGoal) {

    public record RecentActivityItem(String habitName, String completedAt, String icon) {}

    public record UpcomingReminderItem(String habitName, String scheduledAt) {}

    public record DailyGoal(int completed, int target) {}
}
