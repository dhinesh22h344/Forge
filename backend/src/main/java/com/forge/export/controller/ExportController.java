package com.forge.export.controller;

import com.forge.export.dto.ExportPayload;
import com.forge.export.service.ExportService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * See docs/api/openapi.yaml `/export`, `/import`. Synchronous request/response rather than the
 * async-job shape the original spec sketch implied — there's no job queue/worker infrastructure
 * anywhere else in this codebase, and a personal user's data set is small enough that generating
 * or restoring it inline is fast enough not to need one.
 */
@RestController
@RequestMapping("/api/v1")
public class ExportController {

    private final ExportService exportService;

    public ExportController(ExportService exportService) {
        this.exportService = exportService;
    }

    @GetMapping("/export")
    public ExportPayload export() {
        return exportService.export();
    }

    @PostMapping("/import")
    public void importData(@Valid @RequestBody ExportPayload payload) {
        exportService.importData(payload);
    }
}
