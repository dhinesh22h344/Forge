package com.forge.habit.service;

import com.forge.common.exception.ResourceNotFoundException;
import com.forge.common.validation.SecurityUtils;
import com.forge.habit.dto.HabitReminderRequest;
import com.forge.habit.dto.HabitReminderResponse;
import com.forge.habit.entity.Habit;
import com.forge.habit.entity.HabitReminder;
import com.forge.habit.mapper.HabitMapper;
import com.forge.habit.repository.HabitReminderRepository;
import com.forge.habit.repository.HabitRepository;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class HabitReminderService {

    private final HabitReminderRepository reminderRepository;
    private final HabitRepository habitRepository;
    private final HabitMapper habitMapper;

    public HabitReminderService(HabitReminderRepository reminderRepository, HabitRepository habitRepository, HabitMapper habitMapper) {
        this.reminderRepository = reminderRepository;
        this.habitRepository = habitRepository;
        this.habitMapper = habitMapper;
    }

    @Transactional(readOnly = true)
    public List<HabitReminderResponse> list(UUID habitId) {
        assertOwned(habitId);
        return reminderRepository.findByHabitId(habitId).stream().map(habitMapper::toResponse).toList();
    }

    public HabitReminderResponse create(UUID habitId, HabitReminderRequest request) {
        assertOwned(habitId);
        HabitReminder reminder = new HabitReminder(habitId, request.localTime(), request.daysOfWeek());
        reminder.setActive(request.active());
        return habitMapper.toResponse(reminderRepository.save(reminder));
    }

    public void delete(UUID habitId, UUID reminderId) {
        assertOwned(habitId);
        reminderRepository.deleteByHabitIdAndId(habitId, reminderId);
    }

    private void assertOwned(UUID habitId) {
        UUID userId = SecurityUtils.getCurrentUserId();
        Habit habit = habitRepository.findByIdAndUserId(habitId, userId).orElseThrow(() -> ResourceNotFoundException.of("Habit", habitId));
        if (!habit.getUserId().equals(userId)) {
            throw ResourceNotFoundException.of("Habit", habitId);
        }
    }
}
