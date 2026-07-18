package com.forge.dashboard.controller;

import com.forge.dashboard.dto.DashboardSummaryResponse;
import com.forge.dashboard.dto.DashboardWidgetDto;
import com.forge.dashboard.service.DashboardService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** See docs/api/openapi.yaml `/dashboard`, `/dashboard/widgets`. */
@RestController
@RequestMapping("/api/v1/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping
    public DashboardSummaryResponse getSummary() {
        return dashboardService.getSummary();
    }

    @GetMapping("/widgets")
    public List<DashboardWidgetDto> getWidgetLayout() {
        return dashboardService.getWidgetLayout();
    }

    @PutMapping("/widgets")
    public void saveWidgetLayout(@Valid @RequestBody List<DashboardWidgetDto> layout) {
        dashboardService.saveWidgetLayout(layout);
    }
}
