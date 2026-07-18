package com.forge.export.service;

import com.forge.category.entity.Category;
import com.forge.category.repository.CategoryRepository;
import com.forge.common.validation.SecurityUtils;
import com.forge.export.dto.CategoryExport;
import com.forge.export.dto.ExportPayload;
import com.forge.export.dto.HabitExport;
import com.forge.export.dto.HabitLogExport;
import com.forge.export.dto.JournalEntryExport;
import com.forge.habit.entity.Habit;
import com.forge.habit.repository.HabitRepository;
import com.forge.habitlog.entity.HabitLog;
import com.forge.habitlog.repository.HabitLogRepository;
import com.forge.journal.entity.JournalEntry;
import com.forge.journal.repository.JournalEntryRepository;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Aggregates one user's data across modules into a single portable JSON payload, and restores
 * one back. Mirrors how {@code DashboardService} pulls straight from each module's repository
 * rather than going through each module's own service layer — export/import needs full entity
 * access (all fields, not a single DTO shape), and import needs to control id assignment
 * directly, neither of which the per-module Services are built for.
 *
 * <p>Import is always additive: every row gets a freshly minted id (see {@link
 * com.forge.common.audit.BaseEntity}), so re-importing the same backup — or importing into an
 * account that already has data — never overwrites anything, it just adds another copy. The one
 * exception is journal entries, which have a real (user_id, entry_date) uniqueness constraint;
 * those upsert in place so re-importing doesn't 500 on a duplicate day.
 */
@Service
@Transactional
public class ExportService {

    private final CategoryRepository categoryRepository;
    private final HabitRepository habitRepository;
    private final HabitLogRepository habitLogRepository;
    private final JournalEntryRepository journalEntryRepository;

    public ExportService(
            CategoryRepository categoryRepository,
            HabitRepository habitRepository,
            HabitLogRepository habitLogRepository,
            JournalEntryRepository journalEntryRepository) {
        this.categoryRepository = categoryRepository;
        this.habitRepository = habitRepository;
        this.habitLogRepository = habitLogRepository;
        this.journalEntryRepository = journalEntryRepository;
    }

    @Transactional(readOnly = true)
    public ExportPayload export() {
        UUID userId = SecurityUtils.getCurrentUserId();

        var categories = categoryRepository.findByUserIdOrderByCreatedAt(userId).stream()
                .map(c -> new CategoryExport(c.getId(), c.getName(), c.getColor(), c.getGradient(), c.getIcon(), c.getDescription()))
                .toList();

        var habits = habitRepository.findByUserIdOrderByCreatedAt(userId).stream()
                .map(h -> new HabitExport(
                        h.getId(),
                        h.getCategoryId(),
                        h.getName(),
                        h.getDescription(),
                        h.getIcon(),
                        h.getEmoji(),
                        h.getImageUrl(),
                        h.getPriority(),
                        h.getDifficulty(),
                        h.getRepeatType(),
                        h.getRepeatConfig(),
                        h.getGoalValue(),
                        h.getGoalUnit(),
                        h.getEstimatedTimeMinutes(),
                        h.getColor(),
                        h.getGradient(),
                        h.getStartDate(),
                        h.getEndDate(),
                        h.getNotes(),
                        h.getTags(),
                        h.getFolder(),
                        h.getStatus(),
                        h.isArchived()))
                .toList();

        var habitLogs = habitLogRepository.findByUserId(userId).stream()
                .map(l -> new HabitLogExport(l.getHabitId(), l.getLogDate(), l.getStatus(), l.getProgressValue(), l.getNotes()))
                .toList();

        var journalEntries = journalEntryRepository.findByUserIdOrderByEntryDateDesc(userId).stream()
                .map(j -> new JournalEntryExport(j.getEntryDate(), j.getContent(), j.getMood()))
                .toList();

        return new ExportPayload(Instant.now(), categories, habits, habitLogs, journalEntries);
    }

    public void importData(ExportPayload payload) {
        UUID userId = SecurityUtils.getCurrentUserId();

        Map<UUID, UUID> categoryIdMap = new HashMap<>();
        for (CategoryExport c : payload.categories()) {
            Category saved = categoryRepository.save(new Category(userId, c.name(), c.color(), c.gradient(), c.icon(), c.description()));
            categoryIdMap.put(c.id(), saved.getId());
        }

        Map<UUID, UUID> habitIdMap = new HashMap<>();
        for (HabitExport h : payload.habits()) {
            UUID categoryId = categoryIdMap.get(h.categoryId());
            if (categoryId == null) {
                throw new IllegalArgumentException("Habit \"" + h.name() + "\" references a category not present in this export");
            }
            Habit saved = habitRepository.save(new Habit(
                    userId,
                    categoryId,
                    h.name(),
                    h.description(),
                    h.icon(),
                    h.emoji(),
                    h.imageUrl(),
                    h.priority(),
                    h.difficulty(),
                    h.repeatType(),
                    h.repeatConfig(),
                    h.goalValue(),
                    h.goalUnit(),
                    h.estimatedTimeMinutes(),
                    h.color(),
                    h.gradient(),
                    h.startDate(),
                    h.endDate(),
                    h.notes(),
                    h.tags(),
                    h.folder()));
            saved.setStatus(h.status());
            saved.setArchived(h.archived());
            habitIdMap.put(h.id(), saved.getId());
        }

        for (HabitLogExport l : payload.habitLogs()) {
            UUID habitId = habitIdMap.get(l.habitId());
            if (habitId == null) continue; // habit itself failed/absent from this export — skip its logs too
            habitLogRepository.save(new HabitLog(habitId, userId, l.logDate(), l.status(), l.progressValue(), l.notes()));
        }

        for (JournalEntryExport j : payload.journalEntries()) {
            JournalEntry entry = journalEntryRepository.findByUserIdAndEntryDate(userId, j.entryDate()).orElse(null);
            if (entry == null) {
                entry = new JournalEntry(userId, j.entryDate(), j.content(), j.mood());
            } else {
                entry.setContent(j.content());
                entry.setMood(j.mood());
            }
            journalEntryRepository.save(entry);
        }
    }
}
