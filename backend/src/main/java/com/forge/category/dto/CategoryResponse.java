package com.forge.category.dto;

import java.time.Instant;
import java.util.UUID;

public record CategoryResponse(
        UUID id,
        String name,
        String color,
        String gradient,
        String icon,
        String description,
        Instant createdAt,
        Instant updatedAt) {}
