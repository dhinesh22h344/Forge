package com.forge.achievement.service;

import com.forge.achievement.catalog.AchievementCode;
import com.forge.achievement.dto.AchievementResponse;
import com.forge.achievement.dto.AchievementStats;
import com.forge.achievement.entity.UserAchievement;
import com.forge.achievement.repository.UserAchievementRepository;
import com.forge.category.repository.CategoryRepository;
import com.forge.common.validation.SecurityUtils;
import com.forge.habit.entity.Habit;
import com.forge.habit.repository.HabitRepository;
import com.forge.habitlog.repository.HabitLogRepository;
import com.forge.habitlog.service.StreakService;
import com.forge.user.entity.User;
import com.forge.user.repository.UserRepository;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Evaluates the static {@link AchievementCode} catalog against a fresh {@link AchievementStats}
 * snapshot and persists newly-earned unlocks. Called as a side effect of the actions that can
 * possibly move the numbers (see HabitLogService#upsert, CategoryService#create,
 * HabitService#create) rather than on a schedule — achievements should feel immediate.
 */
@Service
@Transactional
public class AchievementService {

    private final UserAchievementRepository userAchievementRepository;
    private final UserRepository userRepository;
    private final HabitRepository habitRepository;
    private final HabitLogRepository habitLogRepository;
    private final CategoryRepository categoryRepository;
    private final StreakService streakService;

    public AchievementService(
            UserAchievementRepository userAchievementRepository,
            UserRepository userRepository,
            HabitRepository habitRepository,
            HabitLogRepository habitLogRepository,
            CategoryRepository categoryRepository,
            StreakService streakService) {
        this.userAchievementRepository = userAchievementRepository;
        this.userRepository = userRepository;
        this.habitRepository = habitRepository;
        this.habitLogRepository = habitLogRepository;
        this.categoryRepository = categoryRepository;
        this.streakService = streakService;
    }

    @Transactional(readOnly = true)
    public List<AchievementResponse> list() {
        UUID userId = SecurityUtils.getCurrentUserId();
        Map<String, UserAchievement> unlocked = userAchievementRepository.findByUserId(userId).stream()
                .collect(Collectors.toMap(UserAchievement::getAchievementCode, ua -> ua));

        return java.util.Arrays.stream(AchievementCode.values())
                .map(code -> {
                    UserAchievement unlock = unlocked.get(code.name());
                    boolean isUnlocked = unlock != null;
                    boolean masked = code.isHidden() && !isUnlocked;
                    return new AchievementResponse(
                            code.name(),
                            masked ? "???" : code.getTitle(),
                            masked ? "Keep going to reveal this achievement." : code.getDescription(),
                            masked ? "lock_rounded" : code.getIcon(),
                            code.isHidden(),
                            isUnlocked,
                            isUnlocked ? unlock.getUnlockedAt() : null);
                })
                .toList();
    }

    /** Returns the achievements newly unlocked by this call (empty if none) — the mobile client
     * uses this to trigger the unlock animation instead of diffing the full list itself. */
    public List<AchievementCode> evaluateForUser(UUID userId) {
        AchievementStats stats = computeStats(userId);
        Set<String> alreadyUnlocked = userAchievementRepository.findByUserId(userId).stream()
                .map(UserAchievement::getAchievementCode)
                .collect(Collectors.toSet());

        List<AchievementCode> newlyUnlocked = new ArrayList<>();
        for (AchievementCode code : AchievementCode.values()) {
            if (alreadyUnlocked.contains(code.name())) continue;
            if (code.isSatisfiedBy(stats)) {
                userAchievementRepository.save(new UserAchievement(userId, code.name()));
                newlyUnlocked.add(code);
            }
        }
        return newlyUnlocked;
    }

    private AchievementStats computeStats(UUID userId) {
        User user = userRepository.findById(userId).orElseThrow();
        List<Habit> activeHabits = habitRepository.findByUserIdAndArchivedOrderByCreatedAt(userId, false);

        long totalCompletions = habitLogRepository.countByUserIdAndStatus(userId, "COMPLETED");
        int bestHabitStreak = activeHabits.stream()
                .mapToInt(h -> streakService.computeHabitStreak(h).bestStreak())
                .max()
                .orElse(0);
        int bestPerfectDayStreak = streakService.computeUserStreak(userId).bestStreak();
        long categoryCount = categoryRepository.countByUserId(userId);

        return new AchievementStats(
                totalCompletions, user.getLevel(), bestHabitStreak, bestPerfectDayStreak, categoryCount, activeHabits.size());
    }
}
