package com.forge.report.dto;

/** See docs/api/openapi.yaml `/reports/overview`. */
public record ReportOverviewResponse(
        String range,
        long totalCompletions,
        long totalMissed,
        double completionRate,
        int currentStreak,
        int bestStreak,
        long xpEarned,
        int level,
        long activeHabitCount) {}
