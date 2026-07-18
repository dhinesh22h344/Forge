package com.forge.habit.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.forge.common.exception.ResourceNotFoundException;
import com.forge.habit.dto.HabitReminderRequest;
import com.forge.habit.entity.Habit;
import com.forge.habit.entity.HabitReminder;
import com.forge.habit.mapper.HabitMapper;
import com.forge.habit.repository.HabitReminderRepository;
import com.forge.habit.repository.HabitRepository;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
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

@ExtendWith(MockitoExtension.class)
class HabitReminderServiceTest {

    @Mock private HabitReminderRepository reminderRepository;
    @Mock private HabitRepository habitRepository;

    private HabitReminderService service;
    private UUID userId;
    private Habit habit;

    @BeforeEach
    void setUp() {
        service = new HabitReminderService(reminderRepository, habitRepository, new HabitMapper());
        userId = UUID.randomUUID();
        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken(userId.toString(), null, null));

        habit = new Habit(
                userId,
                UUID.randomUUID(),
                "Meditate",
                null,
                null,
                null,
                null,
                (short) 2,
                (short) 1,
                "DAILY",
                Map.of(),
                null,
                null,
                null,
                "#00D9C0",
                null,
                LocalDate.now(),
                null,
                null,
                List.of(),
                null);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void createSavesAReminderForAnOwnedHabit() {
        when(habitRepository.findByIdAndUserId(habit.getId(), userId)).thenReturn(Optional.of(habit));
        when(reminderRepository.save(any(HabitReminder.class))).thenAnswer(inv -> inv.getArgument(0));

        var response = service.create(habit.getId(), new HabitReminderRequest(LocalTime.of(7, 30), List.of("MON"), true));

        assertThat(response.localTime()).isEqualTo(LocalTime.of(7, 30));
        assertThat(response.daysOfWeek()).containsExactly("MON");
        assertThat(response.active()).isTrue();
    }

    @Test
    void createRejectsAHabitTheCallerDoesNotOwn() {
        when(habitRepository.findByIdAndUserId(habit.getId(), userId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.create(habit.getId(), new HabitReminderRequest(LocalTime.of(7, 30), List.of(), true)))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void updateChangesTimeDaysAndActiveOnTheExistingRow() {
        HabitReminder existing = new HabitReminder(habit.getId(), LocalTime.of(7, 0), List.of("MON", "WED"));
        when(habitRepository.findByIdAndUserId(habit.getId(), userId)).thenReturn(Optional.of(habit));
        when(reminderRepository.findByHabitIdAndId(habit.getId(), existing.getId())).thenReturn(Optional.of(existing));

        var response = service.update(
                habit.getId(), existing.getId(), new HabitReminderRequest(LocalTime.of(20, 0), List.of("FRI"), false));

        assertThat(response.localTime()).isEqualTo(LocalTime.of(20, 0));
        assertThat(response.daysOfWeek()).containsExactly("FRI");
        assertThat(response.active()).isFalse();
    }
}
