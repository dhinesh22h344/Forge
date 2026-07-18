package com.forge.habit.dto;

import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public record HabitReminderResponse(UUID id, LocalTime localTime, List<String> daysOfWeek, boolean active) {}
