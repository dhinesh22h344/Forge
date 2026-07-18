package com.forge.habit.service;

import com.forge.habit.entity.Habit;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

/**
 * Answers "was this habit supposed to happen on this date" — the one piece of logic that
 * streaks, today's-progress, and reports all depend on, so it lives in one place rather than
 * being re-derived per feature.
 */
@Component
public class RepeatScheduleEvaluator {

    public boolean isScheduledOn(Habit habit, LocalDate date) {
        if (date.isBefore(habit.getStartDate())) return false;
        if (habit.getEndDate() != null && date.isAfter(habit.getEndDate())) return false;

        DayOfWeek dow = date.getDayOfWeek();
        return switch (habit.getRepeatType()) {
            case "DAILY" -> true;
            case "WEEKDAYS" -> dow != DayOfWeek.SATURDAY && dow != DayOfWeek.SUNDAY;
            case "WEEKENDS" -> dow == DayOfWeek.SATURDAY || dow == DayOfWeek.SUNDAY;
            case "SPECIFIC_DAYS" -> matchesSpecificDays(habit.getRepeatConfig(), dow);
            case "MONTHLY" -> matchesDayOfMonth(habit.getRepeatConfig(), date);
            case "YEARLY" -> matchesMonthAndDay(habit.getRepeatConfig(), date);
            // CUSTOM is intentionally open-ended (see product-spec.md non-goals on Custom
            // Schedule UI) — every day is treated as schedulable and completion is
            // opt-in, so streaks still work without a rule engine for arbitrary schedules.
            case "CUSTOM" -> true;
            default -> true;
        };
    }

    @SuppressWarnings("unchecked")
    private boolean matchesSpecificDays(Map<String, Object> config, DayOfWeek dow) {
        Object days = config.get("days");
        if (!(days instanceof List<?> list)) return false;
        String abbrev = dow.name().substring(0, 3);
        return ((List<Object>) list).stream().anyMatch(d -> abbrev.equalsIgnoreCase(String.valueOf(d)));
    }

    private boolean matchesDayOfMonth(Map<String, Object> config, LocalDate date) {
        Object dayOfMonth = config.get("dayOfMonth");
        if (dayOfMonth == null) return false;
        int configured = Integer.parseInt(String.valueOf(dayOfMonth));
        int lastDayOfMonth = date.lengthOfMonth();
        // Clamp so a "31st" habit still fires on 30-day months instead of silently skipping.
        return date.getDayOfMonth() == Math.min(configured, lastDayOfMonth);
    }

    private boolean matchesMonthAndDay(Map<String, Object> config, LocalDate date) {
        Object month = config.get("month");
        Object day = config.get("day");
        if (month == null || day == null) return false;
        return date.getMonthValue() == Integer.parseInt(String.valueOf(month))
                && date.getDayOfMonth() == Integer.parseInt(String.valueOf(day));
    }
}
