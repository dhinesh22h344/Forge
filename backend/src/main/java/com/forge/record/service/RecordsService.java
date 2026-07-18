package com.forge.record.service;

import com.forge.common.validation.SecurityUtils;
import com.forge.habit.entity.Habit;
import com.forge.habit.repository.HabitRepository;
import com.forge.habitlog.dto.StreakResponse;
import com.forge.habitlog.entity.HabitLog;
import com.forge.habitlog.repository.HabitLogRepository;
import com.forge.habitlog.service.StreakService;
import com.forge.record.dto.HabitRecordResponse;
import com.forge.record.dto.PersonalRecordsResponse;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Personal Records: all-time bests, computed on read the same way streaks are — see
 * {@link StreakService}. Deliberately reuses {@code StreakService.computeHabitStreak} (uncapped)
 * rather than {@code ReportService.overview()}, which caps lookback at 365 days for its own
 * heatmap/category-performance cost reasons and would silently understate a genuinely old record.
 */
@Service
@Transactional(readOnly = true)
public class RecordsService {

    private final HabitRepository habitRepository;
    private final HabitLogRepository habitLogRepository;
    private final StreakService streakService;

    public RecordsService(HabitRepository habitRepository, HabitLogRepository habitLogRepository, StreakService streakService) {
        this.habitRepository = habitRepository;
        this.habitLogRepository = habitLogRepository;
        this.streakService = streakService;
    }

    public PersonalRecordsResponse compute() {
        UUID userId = SecurityUtils.getCurrentUserId();
        List<Habit> activeHabits = habitRepository.findByUserIdAndArchivedOrderByCreatedAt(userId, false);
        List<HabitLog> allCompleted = habitLogRepository.findByUserIdAndStatus(userId, "COMPLETED");

        Map<UUID, Long> completionsByHabit = new HashMap<>();
        Map<LocalDate, Long> completionsByDate = new HashMap<>();
        for (HabitLog log : allCompleted) {
            completionsByHabit.merge(log.getHabitId(), 1L, Long::sum);
            completionsByDate.merge(log.getLogDate(), 1L, Long::sum);
        }

        List<HabitRecordResponse> perHabit = new ArrayList<>();
        int bestStreakEver = 0;
        Habit bestStreakHabit = null;
        for (Habit habit : activeHabits) {
            StreakResponse streak = streakService.computeHabitStreak(habit);
            long habitCompletions = completionsByHabit.getOrDefault(habit.getId(), 0L);
            perHabit.add(new HabitRecordResponse(
                    habit.getId(), habit.getName(), habit.getColor(), habit.getIcon(), habit.getEmoji(), streak.bestStreak(), habitCompletions));
            if (streak.bestStreak() > bestStreakEver) {
                bestStreakEver = streak.bestStreak();
                bestStreakHabit = habit;
            }
        }
        perHabit.sort((a, b) -> Integer.compare(b.bestStreak(), a.bestStreak()));

        LocalDate bestDay = null;
        long bestDayCount = 0;
        for (Map.Entry<LocalDate, Long> entry : completionsByDate.entrySet()) {
            if (entry.getValue() > bestDayCount) {
                bestDayCount = entry.getValue();
                bestDay = entry.getKey();
            }
        }

        int bestPerfectDayStreak = streakService.computeUserStreak(userId).bestStreak();

        return new PersonalRecordsResponse(
                allCompleted.size(),
                bestStreakEver,
                bestStreakHabit == null ? null : bestStreakHabit.getId(),
                bestStreakHabit == null ? null : bestStreakHabit.getName(),
                bestPerfectDayStreak,
                bestDay,
                (int) bestDayCount,
                perHabit);
    }
}
