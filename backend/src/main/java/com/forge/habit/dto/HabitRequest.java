package com.forge.habit.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public record HabitRequest(
        @NotNull UUID categoryId,
        @NotBlank @Size(max = 100) String name,
        @Size(max = 1000) String description,
        String icon,
        String emoji,
        String imageUrl,
        @Min(1) @Max(3) short priority,
        @Min(1) @Max(5) short difficulty,
        @NotBlank String repeatType,
        Map<String, Object> repeatConfig,
        BigDecimal goalValue,
        String goalUnit,
        Integer estimatedTimeMinutes,
        @NotBlank String color,
        String gradient,
        @NotNull LocalDate startDate,
        LocalDate endDate,
        @Size(max = 2000) String notes,
        List<String> tags,
        String folder) {}
