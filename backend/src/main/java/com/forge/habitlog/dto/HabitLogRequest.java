package com.forge.habitlog.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.math.BigDecimal;
import java.time.LocalDate;

public record HabitLogRequest(
        @NotNull LocalDate logDate,
        @NotNull @Pattern(regexp = "COMPLETED|MISSED|SKIPPED") String status,
        BigDecimal progressValue,
        String notes) {}
