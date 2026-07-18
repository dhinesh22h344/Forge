package com.forge.habitlog.controller;

import com.forge.habitlog.dto.HabitLogRequest;
import com.forge.habitlog.dto.HabitLogResponse;
import com.forge.habitlog.dto.StreakResponse;
import com.forge.habitlog.service.HabitLogService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** See docs/api/openapi.yaml `/habits/{id}/logs`. */
@RestController
@RequestMapping("/api/v1/habits/{habitId}/logs")
public class HabitLogController {

    private final HabitLogService habitLogService;

    public HabitLogController(HabitLogService habitLogService) {
        this.habitLogService = habitLogService;
    }

    @GetMapping
    public List<HabitLogResponse> list(@PathVariable UUID habitId) {
        return habitLogService.list(habitId);
    }

    @PostMapping
    public HabitLogResponse upsert(@PathVariable UUID habitId, @Valid @RequestBody HabitLogRequest request) {
        return habitLogService.upsert(habitId, request);
    }

    @GetMapping("/streak")
    public StreakResponse streak(@PathVariable UUID habitId) {
        return habitLogService.habitStreak(habitId);
    }
}
