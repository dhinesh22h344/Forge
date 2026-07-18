package com.forge.journal.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record JournalEntryRequest(
        @NotBlank String content,
        @Pattern(regexp = "GREAT|GOOD|OKAY|LOW|ROUGH") String mood) {}
