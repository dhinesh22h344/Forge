package com.forge.export.dto;

import java.util.UUID;

public record CategoryExport(UUID id, String name, String color, String gradient, String icon, String description) {}
