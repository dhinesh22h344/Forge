package com.forge.record.dto;

import java.util.UUID;

public record HabitRecordResponse(
        UUID habitId, String habitName, String habitColor, String habitIcon, String habitEmoji, int bestStreak, long totalCompletions) {}
