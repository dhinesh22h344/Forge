package com.forge.record.controller;

import com.forge.record.dto.PersonalRecordsResponse;
import com.forge.record.service.RecordsService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** See docs/api/openapi.yaml `/records`. */
@RestController
@RequestMapping("/api/v1/records")
public class RecordsController {

    private final RecordsService recordsService;

    public RecordsController(RecordsService recordsService) {
        this.recordsService = recordsService;
    }

    @GetMapping
    public PersonalRecordsResponse get() {
        return recordsService.compute();
    }
}
