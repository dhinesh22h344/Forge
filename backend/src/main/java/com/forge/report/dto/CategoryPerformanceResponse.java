package com.forge.report.dto;

public record CategoryPerformanceResponse(
        String categoryId,
        String categoryName,
        String color,
        long habitCount,
        long totalCompletions,
        long totalScheduled,
        double completionRate) {}
