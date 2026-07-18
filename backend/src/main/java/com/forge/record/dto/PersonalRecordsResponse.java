package com.forge.record.dto;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * All-time bests — deliberately unbounded, unlike {@code ReportOverview} which caps lookback at
 * 365 days for its own cost reasons (see ReportService.MAX_LOOKBACK_DAYS). Nothing here is
 * capped; a record earned three years ago still shows up today.
 */
public record PersonalRecordsResponse(
        long totalCompletionsAllTime,
        int bestStreakEver,
        UUID bestStreakHabitId,
        String bestStreakHabitName,
        int bestPerfectDayStreakEver,
        LocalDate bestSingleDayDate,
        int bestSingleDayCompletions,
        List<HabitRecordResponse> perHabitRecords) {}
