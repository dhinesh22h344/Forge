package com.forge.habitlog.service;

import com.forge.habit.entity.Habit;
import com.forge.habit.repository.HabitRepository;
import com.forge.habit.service.RepeatScheduleEvaluator;
import com.forge.habitlog.dto.StreakResponse;
import com.forge.habitlog.entity.HabitLog;
import com.forge.habitlog.repository.HabitLogRepository;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Streaks are computed on read from habit_logs, never stored — see
 * docs/architecture/database-schema.md "streaks is not a stored table". Acceptable cost at
 * current scale; revisit with a materialized view alongside Milestone 7 (Reports) if this
 * becomes a hot path.
 */
@Service
@Transactional(readOnly = true)
public class StreakService {

    private final HabitRepository habitRepository;
    private final HabitLogRepository habitLogRepository;
    private final RepeatScheduleEvaluator scheduleEvaluator;

    public StreakService(HabitRepository habitRepository, HabitLogRepository habitLogRepository, RepeatScheduleEvaluator scheduleEvaluator) {
        this.habitRepository = habitRepository;
        this.habitLogRepository = habitLogRepository;
        this.scheduleEvaluator = scheduleEvaluator;
    }

    public StreakResponse computeHabitStreak(Habit habit) {
        LocalDate today = LocalDate.now();
        LocalDate rangeStart = habit.getStartDate();
        if (rangeStart.isAfter(today)) return new StreakResponse(0, 0);

        Set<LocalDate> completedDates = new HashSet<>();
        for (HabitLog log : habitLogRepository.findByHabitIdAndLogDateBetweenOrderByLogDate(habit.getId(), rangeStart, today)) {
            if ("COMPLETED".equals(log.getStatus())) completedDates.add(log.getLogDate());
        }

        List<LocalDate> scheduledDates = scheduledDatesInRange(habit, rangeStart, today);
        int best = longestRun(scheduledDates, completedDates);
        int current = currentRun(scheduledDates, completedDates, today);
        return new StreakResponse(current, best);
    }

    public StreakResponse computeUserStreak(UUID userId) {
        List<Habit> habits = habitRepository.findByUserIdAndArchivedOrderByCreatedAt(userId, false);
        if (habits.isEmpty()) return new StreakResponse(0, 0);

        LocalDate today = LocalDate.now();
        LocalDate rangeStart = habits.stream().map(Habit::getStartDate).min(LocalDate::compareTo).orElse(today);
        if (rangeStart.isAfter(today)) return new StreakResponse(0, 0);

        Set<String> completedHabitDateKeys = new HashSet<>();
        for (HabitLog log : habitLogRepository.findByUserIdAndLogDateBetweenOrderByLogDate(userId, rangeStart, today)) {
            if ("COMPLETED".equals(log.getStatus())) {
                completedHabitDateKeys.add(log.getHabitId() + "|" + log.getLogDate());
            }
        }

        // A day counts toward the streak only if it had at least one scheduled habit and every
        // scheduled habit was completed. Days with nothing scheduled are neutral — they neither
        // extend nor break the streak.
        List<LocalDate> successfulDays = new java.util.ArrayList<>();
        List<LocalDate> neutralDays = new java.util.ArrayList<>();
        for (LocalDate date = rangeStart; !date.isAfter(today); date = date.plusDays(1)) {
            final LocalDate d = date;
            List<Habit> scheduledToday = habits.stream().filter(h -> scheduleEvaluator.isScheduledOn(h, d)).toList();
            if (scheduledToday.isEmpty()) {
                neutralDays.add(d);
                continue;
            }
            boolean allCompleted = scheduledToday.stream().allMatch(h -> completedHabitDateKeys.contains(h.getId() + "|" + d));
            if (allCompleted) successfulDays.add(d);
        }

        Set<LocalDate> successfulSet = new HashSet<>(successfulDays);
        List<LocalDate> allDates = new java.util.ArrayList<>();
        for (LocalDate date = rangeStart; !date.isAfter(today); date = date.plusDays(1)) allDates.add(date);
        Set<LocalDate> neutralSet = new HashSet<>(neutralDays);

        int best = longestRunIgnoringNeutral(allDates, successfulSet, neutralSet);
        int current = currentRunIgnoringNeutral(allDates, successfulSet, neutralSet, today);
        return new StreakResponse(current, best);
    }

    private List<LocalDate> scheduledDatesInRange(Habit habit, LocalDate start, LocalDate end) {
        List<LocalDate> dates = new java.util.ArrayList<>();
        for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
            if (scheduleEvaluator.isScheduledOn(habit, date)) dates.add(date);
        }
        return dates;
    }

    private int longestRun(List<LocalDate> scheduledDates, Set<LocalDate> completedDates) {
        int best = 0;
        int running = 0;
        for (LocalDate date : scheduledDates) {
            if (completedDates.contains(date)) {
                running++;
                best = Math.max(best, running);
            } else {
                running = 0;
            }
        }
        return best;
    }

    private int currentRun(List<LocalDate> scheduledDates, Set<LocalDate> completedDates, LocalDate today) {
        int current = 0;
        for (int i = scheduledDates.size() - 1; i >= 0; i--) {
            LocalDate date = scheduledDates.get(i);
            boolean completed = completedDates.contains(date);
            if (!completed && date.equals(today)) {
                // Today isn't over yet — don't let an unfinished today break the streak.
                continue;
            }
            if (completed) {
                current++;
            } else {
                break;
            }
        }
        return current;
    }

    private int longestRunIgnoringNeutral(List<LocalDate> allDates, Set<LocalDate> successfulSet, Set<LocalDate> neutralSet) {
        int best = 0;
        int running = 0;
        for (LocalDate date : allDates) {
            if (neutralSet.contains(date)) continue;
            if (successfulSet.contains(date)) {
                running++;
                best = Math.max(best, running);
            } else {
                running = 0;
            }
        }
        return best;
    }

    private int currentRunIgnoringNeutral(List<LocalDate> allDates, Set<LocalDate> successfulSet, Set<LocalDate> neutralSet, LocalDate today) {
        int current = 0;
        for (int i = allDates.size() - 1; i >= 0; i--) {
            LocalDate date = allDates.get(i);
            if (neutralSet.contains(date)) continue;
            boolean successful = successfulSet.contains(date);
            if (!successful && date.equals(today)) continue;
            if (successful) {
                current++;
            } else {
                break;
            }
        }
        return current;
    }
}
