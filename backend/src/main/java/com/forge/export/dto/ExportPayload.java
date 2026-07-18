package com.forge.export.dto;

import java.time.Instant;
import java.util.List;

/**
 * Full backup of one user's data. {@code id} fields inside each list entry are the *source*
 * ids — used only to relink cross-references (habit -&gt; category, log -&gt; habit) during
 * import; a fresh id is always minted for every row that's actually persisted, so importing
 * never trusts or reuses ids from the file (see ExportService#importData).
 */
public record ExportPayload(
        Instant exportedAt,
        List<CategoryExport> categories,
        List<HabitExport> habits,
        List<HabitLogExport> habitLogs,
        List<JournalEntryExport> journalEntries) {}
