package com.forge.achievement.dto;

/**
 * Snapshot of the numbers every achievement predicate is checked against — computed once per
 * evaluation (see AchievementService#evaluateForUser) so each {@code AchievementCode} predicate
 * stays a cheap, pure check instead of re-querying the database.
 *
 * <p>Streak fields are all-time bests, not current values, so an unlock stays permanent even
 * after the user later breaks that streak.
 */
public record AchievementStats(
        long totalCompletions,
        int level,
        int bestHabitStreak,
        int bestPerfectDayStreak,
        long categoryCount,
        long activeHabitCount) {}
