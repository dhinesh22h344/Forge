package com.forge.habit.controller;

import com.forge.habit.dto.HabitRequest;
import com.forge.habit.dto.HabitResponse;
import com.forge.habit.service.HabitService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** See docs/api/openapi.yaml `/habits`. */
@RestController
@RequestMapping("/api/v1/habits")
public class HabitController {

    private final HabitService habitService;

    public HabitController(HabitService habitService) {
        this.habitService = habitService;
    }

    @GetMapping
    public List<HabitResponse> list(
            @RequestParam(required = false) UUID categoryId, @RequestParam(required = false) Boolean archived) {
        return habitService.list(categoryId, archived);
    }

    @PostMapping
    public ResponseEntity<HabitResponse> create(@Valid @RequestBody HabitRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(habitService.create(request));
    }

    @GetMapping("/{id}")
    public HabitResponse get(@PathVariable UUID id) {
        return habitService.get(id);
    }

    @PutMapping("/{id}")
    public HabitResponse update(@PathVariable UUID id, @Valid @RequestBody HabitRequest request) {
        return habitService.update(id, request);
    }

    @PatchMapping("/{id}/archive")
    public HabitResponse archive(@PathVariable UUID id) {
        return habitService.setArchived(id, true);
    }

    @PatchMapping("/{id}/unarchive")
    public HabitResponse unarchive(@PathVariable UUID id) {
        return habitService.setArchived(id, false);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        habitService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
