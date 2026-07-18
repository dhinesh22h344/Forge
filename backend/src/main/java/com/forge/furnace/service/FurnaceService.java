package com.forge.furnace.service;

import com.forge.common.exception.ResourceNotFoundException;
import com.forge.common.validation.SecurityUtils;
import com.forge.furnace.dto.FurnaceEmberResponse;
import com.forge.furnace.dto.FurnaceReforgeResponse;
import com.forge.furnace.entity.HabitStreakRecovery;
import com.forge.furnace.repository.HabitStreakRecoveryRepository;
import com.forge.habit.entity.Habit;
import com.forge.habit.repository.HabitRepository;
import com.forge.habit.service.RepeatScheduleEvaluator;
import com.forge.habitlog.dto.HabitLogRequest;
import com.forge.habitlog.dto.StreakResponse;
import com.forge.habitlog.entity.HabitLog;
import com.forge.habitlog.repository.HabitLogRepository;
import com.forge.habitlog.service.HabitLogService;
import com.forge.habitlog.service.StreakService;
import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * The Furnace: non-punitive streak recovery. A missed scheduled day doesn't break a streak the
 * instant it's read — it becomes an "ember," recoverable by backdating that single day to
 * COMPLETED through the end of the day after the miss. Recovery is capped at once per habit per
 * rolling 30 days so it stays meaningful rather than making streaks unbreakable.
 *
 * <p>Nothing about "is there an ember right now" is stored — same read-time-computation
 * philosophy as {@link StreakService}. Only successful reforges are persisted, purely to enforce
 * the cooldown.
 */
@Service
@Transactional(readOnly = true)
public class FurnaceService {

    /** Grace runs through the end of the day after the miss — e.g. miss Monday, reforge any time Tuesday. */
    private static final int GRACE_DAYS = 1;

    private static final int RECOVERY_COOLDOWN_DAYS = 30;

    private final HabitRepository habitRepository;
    private final HabitLogRepository habitLogRepository;
    private final HabitStreakRecoveryRepository recoveryRepository;
    private final RepeatScheduleEvaluator scheduleEvaluator;
    private final StreakService streakService;
    private final HabitLogService habitLogService;

    public FurnaceService(
            HabitRepository habitRepository,
            HabitLogRepository habitLogRepository,
            HabitStreakRecoveryRepository recoveryRepository,
            RepeatScheduleEvaluator scheduleEvaluator,
            StreakService streakService,
            HabitLogService habitLogService) {
        this.habitRepository = habitRepository;
        this.habitLogRepository = habitLogRepository;
        this.recoveryRepository = recoveryRepository;
        this.scheduleEvaluator = scheduleEvaluator;
        this.streakService = streakService;
        this.habitLogService = habitLogService;
    }

    public List<FurnaceEmberResponse> listEmbers() {
        UUID userId = SecurityUtils.getCurrentUserId();
        LocalDate today = LocalDate.now();
        List<Habit> habits = habitRepository.findByUserIdAndArchivedOrderByCreatedAt(userId, false);

        List<FurnaceEmberResponse> embers = new ArrayList<>();
        for (Habit habit : habits) {
            LocalDate missedDate = mostRecentMiss(habit, today);
            if (missedDate == null) continue;
            LocalDate graceDeadline = missedDate.plusDays(GRACE_DAYS);
            if (today.isAfter(graceDeadline)) continue;

            HabitStreakRecovery lastRecovery = recoveryRepository.findTopByHabitIdOrderByCreatedAtDesc(habit.getId()).orElse(null);
            Instant cooldownEndsAt = lastRecovery == null ? null : lastRecovery.getCreatedAt().plus(RECOVERY_COOLDOWN_DAYS, ChronoUnit.DAYS);
            boolean recoverable = cooldownEndsAt == null || Instant.now().isAfter(cooldownEndsAt);

            embers.add(new FurnaceEmberResponse(
                    habit.getId(),
                    habit.getName(),
                    habit.getColor(),
                    habit.getIcon(),
                    habit.getEmoji(),
                    missedDate,
                    graceDeadline,
                    recoverable,
                    recoverable ? null : cooldownEndsAt));
        }
        return embers;
    }

    @Transactional
    public FurnaceReforgeResponse reforge(UUID habitId) {
        UUID userId = SecurityUtils.getCurrentUserId();
        Habit habit = habitRepository.findByIdAndUserId(habitId, userId).orElseThrow(() -> ResourceNotFoundException.of("Habit", habitId));

        LocalDate today = LocalDate.now();
        LocalDate missedDate = mostRecentMiss(habit, today);
        if (missedDate == null) {
            throw new IllegalArgumentException("This habit has no missed day to reforge.");
        }
        if (today.isAfter(missedDate.plusDays(GRACE_DAYS))) {
            throw new IllegalArgumentException("The grace window for this miss has expired.");
        }

        HabitStreakRecovery lastRecovery = recoveryRepository.findTopByHabitIdOrderByCreatedAtDesc(habit.getId()).orElse(null);
        if (lastRecovery != null && lastRecovery.getCreatedAt().isAfter(Instant.now().minus(RECOVERY_COOLDOWN_DAYS, ChronoUnit.DAYS))) {
            throw new IllegalArgumentException("This habit has already been reforged in the last 30 days.");
        }

        habitLogService.upsert(habitId, new HabitLogRequest(missedDate, "COMPLETED", null, "Recovered via The Furnace"));
        recoveryRepository.save(new HabitStreakRecovery(habit.getId(), userId, missedDate));

        StreakResponse streak = streakService.computeHabitStreak(habit);
        return new FurnaceReforgeResponse(habit.getId(), missedDate, streak.currentStreak(), streak.bestStreak());
    }

    /**
     * Walks backward from yesterday to the most recent scheduled date. Returns it only if that
     * date wasn't completed (an active miss); returns null if it was completed (streak intact,
     * nothing to reforge) or if nothing was scheduled recently enough to matter.
     */
    private LocalDate mostRecentMiss(Habit habit, LocalDate today) {
        LocalDate lookbackFloor = today.minusDays(GRACE_DAYS + 1L);
        LocalDate rangeStart = habit.getStartDate().isAfter(lookbackFloor) ? habit.getStartDate() : lookbackFloor;
        LocalDate rangeEnd = today.minusDays(1);
        if (rangeStart.isAfter(rangeEnd)) return null;

        Set<LocalDate> completedDates = habitLogRepository
                .findByHabitIdAndLogDateBetweenOrderByLogDate(habit.getId(), rangeStart, rangeEnd)
                .stream()
                .filter(l -> "COMPLETED".equals(l.getStatus()))
                .map(HabitLog::getLogDate)
                .collect(Collectors.toSet());

        for (LocalDate date = rangeEnd; !date.isBefore(rangeStart); date = date.minusDays(1)) {
            if (!scheduleEvaluator.isScheduledOn(habit, date)) continue;
            return completedDates.contains(date) ? null : date;
        }
        return null;
    }
}
