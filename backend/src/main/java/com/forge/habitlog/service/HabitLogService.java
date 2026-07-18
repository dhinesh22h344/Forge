package com.forge.habitlog.service;

import com.forge.achievement.service.AchievementService;
import com.forge.common.exception.ResourceNotFoundException;
import com.forge.common.validation.SecurityUtils;
import com.forge.habit.entity.Habit;
import com.forge.habit.repository.HabitRepository;
import com.forge.habitlog.dto.HabitLogRequest;
import com.forge.habitlog.dto.HabitLogResponse;
import com.forge.habitlog.dto.StreakResponse;
import com.forge.habitlog.entity.HabitLog;
import com.forge.habitlog.repository.HabitLogRepository;
import com.forge.user.entity.User;
import com.forge.user.repository.UserRepository;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class HabitLogService {

    /** difficulty (1-5) * this = XP per completion. A 5-difficulty habit is worth as much as
     * half a level (see User.addXp's 100-XP-per-level curve) — deliberately front-loaded so
     * early completions feel rewarding. */
    private static final long XP_PER_DIFFICULTY_POINT = 10;

    private final HabitLogRepository habitLogRepository;
    private final HabitRepository habitRepository;
    private final UserRepository userRepository;
    private final StreakService streakService;
    private final AchievementService achievementService;

    public HabitLogService(
            HabitLogRepository habitLogRepository,
            HabitRepository habitRepository,
            UserRepository userRepository,
            StreakService streakService,
            AchievementService achievementService) {
        this.habitLogRepository = habitLogRepository;
        this.habitRepository = habitRepository;
        this.userRepository = userRepository;
        this.streakService = streakService;
        this.achievementService = achievementService;
    }

    @Transactional(readOnly = true)
    public List<HabitLogResponse> list(UUID habitId) {
        Habit habit = findOwnedHabit(habitId);
        return habitLogRepository.findByHabitIdOrderByLogDateDesc(habit.getId()).stream().map(this::toResponse).toList();
    }

    /** Upsert semantics: one log per (habit, date) — POSTing the same day again updates it. */
    public HabitLogResponse upsert(UUID habitId, HabitLogRequest request) {
        UUID userId = SecurityUtils.getCurrentUserId();
        Habit habit = findOwnedHabit(habitId);

        HabitLog log = habitLogRepository
                .findByHabitIdAndLogDate(habit.getId(), request.logDate())
                .orElse(null);

        boolean wasCompleted = log != null && "COMPLETED".equals(log.getStatus());
        boolean nowCompleted = "COMPLETED".equals(request.status());

        if (log == null) {
            log = new HabitLog(habit.getId(), userId, request.logDate(), request.status(), request.progressValue(), request.notes());
        } else {
            log.setStatus(request.status());
            log.setProgressValue(request.progressValue());
            log.setNotes(request.notes());
        }
        log = habitLogRepository.save(log);

        if (nowCompleted != wasCompleted) {
            User user = userRepository.findById(userId).orElseThrow();
            long xpDelta = habit.getDifficulty() * XP_PER_DIFFICULTY_POINT;
            user.addXp(nowCompleted ? xpDelta : -xpDelta);
        }

        achievementService.evaluateForUser(userId);

        return toResponse(log);
    }

    @Transactional(readOnly = true)
    public StreakResponse habitStreak(UUID habitId) {
        return streakService.computeHabitStreak(findOwnedHabit(habitId));
    }

    private Habit findOwnedHabit(UUID habitId) {
        UUID userId = SecurityUtils.getCurrentUserId();
        return habitRepository.findByIdAndUserId(habitId, userId).orElseThrow(() -> ResourceNotFoundException.of("Habit", habitId));
    }

    private HabitLogResponse toResponse(HabitLog log) {
        return new HabitLogResponse(
                log.getId(), log.getHabitId(), log.getLogDate(), log.getStatus(), log.getProgressValue(), log.getNotes(), log.getCompletedAt());
    }
}
