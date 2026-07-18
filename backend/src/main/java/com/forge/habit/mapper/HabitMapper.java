package com.forge.habit.mapper;

import com.forge.habit.dto.HabitReminderResponse;
import com.forge.habit.dto.HabitResponse;
import com.forge.habit.entity.Habit;
import com.forge.habit.entity.HabitReminder;
import org.springframework.stereotype.Component;

@Component
public class HabitMapper {

    public HabitResponse toResponse(Habit habit) {
        return new HabitResponse(
                habit.getId(),
                habit.getCategoryId(),
                habit.getName(),
                habit.getDescription(),
                habit.getIcon(),
                habit.getEmoji(),
                habit.getImageUrl(),
                habit.getPriority(),
                habit.getDifficulty(),
                habit.getRepeatType(),
                habit.getRepeatConfig(),
                habit.getGoalValue(),
                habit.getGoalUnit(),
                habit.getEstimatedTimeMinutes(),
                habit.getColor(),
                habit.getGradient(),
                habit.getStartDate(),
                habit.getEndDate(),
                habit.getNotes(),
                habit.getTags(),
                habit.getFolder(),
                habit.getStatus(),
                habit.isArchived(),
                habit.getCreatedAt(),
                habit.getUpdatedAt());
    }

    public HabitReminderResponse toResponse(HabitReminder reminder) {
        return new HabitReminderResponse(reminder.getId(), reminder.getLocalTime(), reminder.getDaysOfWeek(), reminder.isActive());
    }
}
