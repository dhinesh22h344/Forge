package com.forge.habit.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public record HabitResponse(
        UUID id,
        UUID categoryId,
        String name,
        String description,
        String icon,
        String emoji,
        String imageUrl,
        short priority,
        short difficulty,
        String repeatType,
        Map<String, Object> repeatConfig,
        BigDecimal goalValue,
        String goalUnit,
        Integer estimatedTimeMinutes,
        String color,
        String gradient,
        LocalDate startDate,
        LocalDate endDate,
        String notes,
        List<String> tags,
        String folder,
        String status,
        boolean archived,
        Instant createdAt,
        Instant updatedAt) {}
