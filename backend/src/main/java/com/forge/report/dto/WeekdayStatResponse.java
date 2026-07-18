package com.forge.report.dto;

/** `weekday` is a 3-letter abbreviation (MON..SUN) — one point on the reports radar chart. */
public record WeekdayStatResponse(String weekday, double completionRate) {}
