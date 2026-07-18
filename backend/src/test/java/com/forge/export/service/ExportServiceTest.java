package com.forge.export.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.forge.category.entity.Category;
import com.forge.category.repository.CategoryRepository;
import com.forge.export.dto.CategoryExport;
import com.forge.export.dto.ExportPayload;
import com.forge.export.dto.HabitExport;
import com.forge.export.dto.JournalEntryExport;
import com.forge.habit.entity.Habit;
import com.forge.habit.repository.HabitRepository;
import com.forge.habitlog.repository.HabitLogRepository;
import com.forge.journal.entity.JournalEntry;
import com.forge.journal.repository.JournalEntryRepository;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * Regression coverage for import's core safety property: it never trusts an id from the file.
 * Cross-references (habit -&gt; category) must be relinked through the freshly minted ids, and
 * a reference to a category missing from the payload must fail loudly rather than silently
 * importing an orphaned habit.
 */
@ExtendWith(MockitoExtension.class)
class ExportServiceTest {

    @Mock private CategoryRepository categoryRepository;
    @Mock private HabitRepository habitRepository;
    @Mock private HabitLogRepository habitLogRepository;
    @Mock private JournalEntryRepository journalEntryRepository;

    private ExportService service;
    private UUID userId;

    @BeforeEach
    void setUp() {
        service = new ExportService(categoryRepository, habitRepository, habitLogRepository, journalEntryRepository);
        userId = UUID.randomUUID();
        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken(userId.toString(), null, null));
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void importRemapsHabitCategoryIdToTheFreshlyMintedCategoryId() {
        UUID sourceCategoryId = UUID.randomUUID();
        UUID freshCategoryId = UUID.randomUUID();

        Category savedCategory = new Category(userId, "Fitness", "#6C5CE7", null, "dumbbell", null);
        when(categoryRepository.save(any(Category.class))).thenAnswer(invocation -> savedCategory);
        // Category's id is application-generated in its constructor (see BaseEntity) — we can't
        // control it directly, so assert relinking via the captured argument instead.

        HabitExport habitExport = new HabitExport(
                UUID.randomUUID(),
                sourceCategoryId,
                "Run",
                null,
                null,
                null,
                null,
                (short) 2,
                (short) 3,
                "DAILY",
                Map.of(),
                null,
                null,
                null,
                "#6C5CE7",
                null,
                LocalDate.now(),
                null,
                null,
                List.of(),
                null,
                "ACTIVE",
                false);

        ExportPayload payload = new ExportPayload(
                Instant.now(),
                List.of(new CategoryExport(sourceCategoryId, "Fitness", "#6C5CE7", null, "dumbbell", null)),
                List.of(habitExport),
                List.of(),
                List.of());

        when(habitRepository.save(any(Habit.class))).thenAnswer(invocation -> invocation.getArgument(0));

        service.importData(payload);

        ArgumentCaptor<Habit> savedHabit = ArgumentCaptor.forClass(Habit.class);
        verify(habitRepository).save(savedHabit.capture());
        assertThat(savedHabit.getValue().getCategoryId()).isEqualTo(savedCategory.getId());
        assertThat(savedHabit.getValue().getCategoryId()).isNotEqualTo(sourceCategoryId);
    }

    @Test
    void importRejectsAHabitWhoseCategoryIsMissingFromThePayload() {
        HabitExport orphanHabit = new HabitExport(
                UUID.randomUUID(),
                UUID.randomUUID(), // not present in payload.categories()
                "Run",
                null,
                null,
                null,
                null,
                (short) 2,
                (short) 3,
                "DAILY",
                Map.of(),
                null,
                null,
                null,
                "#6C5CE7",
                null,
                LocalDate.now(),
                null,
                null,
                List.of(),
                null,
                "ACTIVE",
                false);

        ExportPayload payload = new ExportPayload(Instant.now(), List.of(), List.of(orphanHabit), List.of(), List.of());

        assertThatThrownBy(() -> service.importData(payload)).isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void importUpdatesTheExistingJournalEntryInPlaceWhenOneAlreadyExistsForThatDay() {
        LocalDate date = LocalDate.now();
        JournalEntry existing = new JournalEntry(userId, date, "Old content", "OKAY");
        when(journalEntryRepository.findByUserIdAndEntryDate(userId, date)).thenReturn(Optional.of(existing));

        ExportPayload payload =
                new ExportPayload(Instant.now(), List.of(), List.of(), List.of(), List.of(new JournalEntryExport(date, "New content", "GREAT")));

        service.importData(payload);

        verify(journalEntryRepository).save(existing);
        assertThat(existing.getContent()).isEqualTo("New content");
        assertThat(existing.getMood()).isEqualTo("GREAT");
    }
}
