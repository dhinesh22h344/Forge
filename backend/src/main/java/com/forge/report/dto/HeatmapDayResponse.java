package com.forge.report.dto;

import java.time.LocalDate;

public record HeatmapDayResponse(LocalDate date, int scheduledCount, int completedCount, double completionRate) {}
