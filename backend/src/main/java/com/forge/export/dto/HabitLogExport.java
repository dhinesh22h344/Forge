package com.forge.export.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record HabitLogExport(UUID habitId, LocalDate logDate, String status, BigDecimal progressValue, String notes) {}
