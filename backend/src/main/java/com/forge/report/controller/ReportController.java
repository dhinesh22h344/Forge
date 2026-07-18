package com.forge.report.controller;

import com.forge.report.dto.CategoryPerformanceResponse;
import com.forge.report.dto.HeatmapDayResponse;
import com.forge.report.dto.ReportOverviewResponse;
import com.forge.report.dto.ReportRange;
import com.forge.report.dto.WeekdayStatResponse;
import com.forge.report.service.ReportService;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** See docs/api/openapi.yaml `/reports`. */
@RestController
@RequestMapping("/api/v1/reports")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/overview")
    public ReportOverviewResponse overview(@RequestParam(defaultValue = "MONTH") ReportRange range) {
        return reportService.overview(range);
    }

    @GetMapping("/heatmap")
    public List<HeatmapDayResponse> heatmap(@RequestParam(defaultValue = "MONTH") ReportRange range) {
        return reportService.heatmap(range);
    }

    @GetMapping("/category-performance")
    public List<CategoryPerformanceResponse> categoryPerformance(@RequestParam(defaultValue = "MONTH") ReportRange range) {
        return reportService.categoryPerformance(range);
    }

    @GetMapping("/weekday-breakdown")
    public List<WeekdayStatResponse> weekdayBreakdown(@RequestParam(defaultValue = "MONTH") ReportRange range) {
        return reportService.weekdayBreakdown(range);
    }
}
