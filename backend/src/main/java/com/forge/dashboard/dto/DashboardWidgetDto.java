package com.forge.dashboard.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PositiveOrZero;

public record DashboardWidgetDto(@NotBlank String widgetType, @PositiveOrZero int position, boolean isVisible) {}
