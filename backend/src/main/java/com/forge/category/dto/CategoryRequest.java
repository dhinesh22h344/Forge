package com.forge.category.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record CategoryRequest(
        @NotBlank @Size(max = 60) String name,
        @NotBlank @Pattern(regexp = "^#([A-Fa-f0-9]{6})$", message = "must be a hex color like #6C5CE7") String color,
        @Pattern(
                        regexp = "^#([A-Fa-f0-9]{6}),#([A-Fa-f0-9]{6})$",
                        message = "must be two comma-separated hex colors, e.g. #6C5CE7,#00D9C0")
                String gradient,
        @NotBlank @Size(max = 60) String icon,
        @Size(max = 500) String description) {}
