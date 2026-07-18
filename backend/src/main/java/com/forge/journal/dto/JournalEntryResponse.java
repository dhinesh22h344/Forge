package com.forge.journal.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record JournalEntryResponse(
        UUID id, LocalDate entryDate, String content, String mood, Instant createdAt, Instant updatedAt) {}
