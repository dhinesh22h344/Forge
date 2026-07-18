package com.forge.furnace.controller;

import com.forge.furnace.dto.FurnaceEmberResponse;
import com.forge.furnace.dto.FurnaceReforgeResponse;
import com.forge.furnace.service.FurnaceService;
import java.util.List;
import java.util.UUID;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** See docs/api/openapi.yaml `/furnace` and `/habits/{id}/furnace/reforge`. */
@RestController
public class FurnaceController {

    private final FurnaceService furnaceService;

    public FurnaceController(FurnaceService furnaceService) {
        this.furnaceService = furnaceService;
    }

    @GetMapping("/api/v1/furnace")
    public List<FurnaceEmberResponse> listEmbers() {
        return furnaceService.listEmbers();
    }

    @PostMapping("/api/v1/habits/{habitId}/furnace/reforge")
    public FurnaceReforgeResponse reforge(@PathVariable UUID habitId) {
        return furnaceService.reforge(habitId);
    }
}
