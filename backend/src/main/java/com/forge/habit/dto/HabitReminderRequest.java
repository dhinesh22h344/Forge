package com.forge.habit.dto;

import jakarta.validation.constraints.NotNull;
import java.time.LocalTime;
import java.util.List;

public record HabitReminderRequest(@NotNull LocalTime localTime, List<String> daysOfWeek, boolean active) {}
