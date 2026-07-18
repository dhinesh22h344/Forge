package com.forge.export.dto;

import java.time.LocalDate;

public record JournalEntryExport(LocalDate entryDate, String content, String mood) {}
