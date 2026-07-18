package com.forge.report.dto;

import com.forge.habit.entity.Habit;
import java.time.LocalDate;
import java.util.List;

/** Query-param-bindable time window for every report endpoint. */
public enum ReportRange {
    WEEK,
    MONTH,
    YEAR,
    ALL;

    /** Unclamped start date — see ReportService#resolveStart for the 365-day safety cap applied
     * on top of this (an ALL-time user can have habits going back years). */
    public LocalDate startDate(LocalDate today, List<Habit> habits) {
        return switch (this) {
            case WEEK -> today.minusDays(6);
            case MONTH -> today.minusDays(29);
            case YEAR -> today.minusDays(364);
            case ALL -> habits.stream().map(Habit::getStartDate).min(LocalDate::compareTo).orElse(today);
        };
    }
}
