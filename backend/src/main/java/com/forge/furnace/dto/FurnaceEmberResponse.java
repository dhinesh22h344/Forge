package com.forge.furnace.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

/**
 * One habit currently sitting in the furnace — a missed scheduled day still within its grace
 * window. {@code recoverable} is false when the grace window is fine but the 30-day reforge
 * cooldown (see {@code cooldownEndsAt}) hasn't cleared yet.
 */
public record FurnaceEmberResponse(
        UUID habitId,
        String habitName,
        String habitColor,
        String habitIcon,
        String habitEmoji,
        LocalDate missedDate,
        LocalDate graceDeadline,
        boolean recoverable,
        Instant cooldownEndsAt) {}
