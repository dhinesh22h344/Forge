package com.forge.furnace.dto;

import java.time.LocalDate;
import java.util.UUID;

public record FurnaceReforgeResponse(UUID habitId, LocalDate recoveredDate, int currentStreak, int bestStreak) {}
