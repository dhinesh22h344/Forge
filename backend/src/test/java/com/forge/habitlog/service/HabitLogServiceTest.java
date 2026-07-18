package com.forge.habitlog.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.forge.achievement.service.AchievementService;
import com.forge.habit.entity.Habit;
import com.forge.habit.repository.HabitRepository;
import com.forge.habitlog.dto.HabitLogRequest;
import com.forge.habitlog.entity.HabitLog;
import com.forge.habitlog.repository.HabitLogRepository;
import com.forge.user.entity.User;
import com.forge.user.repository.UserRepository;
import java.time.LocalDate;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * Regression coverage for the idempotency guarantee the offline-first mobile queue relies on:
 * replaying the same completion twice must not double-grant XP. See
 * HabitLogService#upsert's wasCompleted/nowCompleted comparison.
 */
@ExtendWith(MockitoExtension.class)
class HabitLogServiceTest {

    @Mock private HabitLogRepository habitLogRepository;
    @Mock private HabitRepository habitRepository;
    @Mock private UserRepository userRepository;
    @Mock private StreakService streakService;
    @Mock private AchievementService achievementService;

    private HabitLogService service;
    private UUID userId;
    private Habit habit;
    private User user;

    @BeforeEach
    void setUp() {
        service = new HabitLogService(habitLogRepository, habitRepository, userRepository, streakService, achievementService);

        userId = UUID.randomUUID();
        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken(userId.toString(), null, null));

        habit = new Habit(
                userId,
                UUID.randomUUID(),
                "Read",
                null,
                null,
                null,
                null,
                (short) 2,
                (short) 3, // difficulty 3 -> 30 XP per completion
                "DAILY",
                Map.of(),
                null,
                null,
                null,
                "#6C5CE7",
                null,
                LocalDate.now(),
                null,
                null,
                java.util.List.of(),
                null);

        user = new User("reader", "reader@example.com", "hash", "UTC", "US", "en", true);

        when(habitRepository.findByIdAndUserId(habit.getId(), userId)).thenReturn(Optional.of(habit));
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(habitLogRepository.save(any(HabitLog.class))).thenAnswer(invocation -> invocation.getArgument(0));
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void firstCompletionGrantsXpForHabitDifficulty() {
        when(habitLogRepository.findByHabitIdAndLogDate(habit.getId(), LocalDate.now())).thenReturn(Optional.empty());

        service.upsert(habit.getId(), new HabitLogRequest(LocalDate.now(), "COMPLETED", null, null));

        assertThat(user.getXp()).isEqualTo(30);
    }

    @Test
    void replayingTheSameCompletionDoesNotDoubleGrantXp() {
        HabitLog existing = new HabitLog(habit.getId(), userId, LocalDate.now(), "COMPLETED", null, null);
        when(habitLogRepository.findByHabitIdAndLogDate(habit.getId(), LocalDate.now()))
                .thenReturn(Optional.empty())
                .thenReturn(Optional.of(existing));

        service.upsert(habit.getId(), new HabitLogRequest(LocalDate.now(), "COMPLETED", null, null));
        assertThat(user.getXp()).isEqualTo(30);

        // Client retries the identical request (e.g. offline-queue replay) —
        // wasCompleted and nowCompleted are both true, so no further XP.
        service.upsert(habit.getId(), new HabitLogRequest(LocalDate.now(), "COMPLETED", null, null));
        assertThat(user.getXp()).isEqualTo(30);
    }

    @Test
    void unmarkingCompletionReversesTheXpGrant() {
        HabitLog existing = new HabitLog(habit.getId(), userId, LocalDate.now(), "COMPLETED", null, null);
        when(habitLogRepository.findByHabitIdAndLogDate(habit.getId(), LocalDate.now()))
                .thenReturn(Optional.empty())
                .thenReturn(Optional.of(existing));

        service.upsert(habit.getId(), new HabitLogRequest(LocalDate.now(), "COMPLETED", null, null));
        assertThat(user.getXp()).isEqualTo(30);

        service.upsert(habit.getId(), new HabitLogRequest(LocalDate.now(), "SKIPPED", null, null));
        assertThat(user.getXp()).isEqualTo(0);
    }
}
