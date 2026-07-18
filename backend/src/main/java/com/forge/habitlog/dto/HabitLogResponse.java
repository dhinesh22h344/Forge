package com.forge.habitlog.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record HabitLogResponse(
        UUID id,
        UUID habitId,
        LocalDate logDate,
        String status,
        BigDecimal progressValue,
        String notes,
        Instant completedAt) {}
