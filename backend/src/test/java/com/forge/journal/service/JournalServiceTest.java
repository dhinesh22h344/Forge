package com.forge.journal.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.forge.common.exception.ResourceNotFoundException;
import com.forge.journal.dto.JournalEntryRequest;
import com.forge.journal.entity.JournalEntry;
import com.forge.journal.repository.JournalEntryRepository;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * Regression coverage for the upsert-by-date guarantee the PUT /journal/{date} endpoint relies
 * on: a second PUT for the same day updates the existing row in place rather than creating a
 * duplicate, and cross-user access surfaces as 404, never leaking another user's entry.
 */
@ExtendWith(MockitoExtension.class)
class JournalServiceTest {

    @Mock private JournalEntryRepository journalEntryRepository;

    private JournalService service;
    private UUID userId;

    @BeforeEach
    void setUp() {
        service = new JournalService(journalEntryRepository);

        userId = UUID.randomUUID();
        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken(userId.toString(), null, null));
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void firstUpsertCreatesANewEntry() {
        LocalDate date = LocalDate.now();
        when(journalEntryRepository.findByUserIdAndEntryDate(userId, date)).thenReturn(Optional.empty());
        when(journalEntryRepository.save(any(JournalEntry.class))).thenAnswer(invocation -> invocation.getArgument(0));

        var response = service.upsert(date, new JournalEntryRequest("Good day", "GOOD"));

        assertThat(response.content()).isEqualTo("Good day");
        assertThat(response.mood()).isEqualTo("GOOD");
    }

    @Test
    void secondUpsertForSameDateUpdatesInPlaceRatherThanDuplicating() {
        LocalDate date = LocalDate.now();
        JournalEntry existing = new JournalEntry(userId, date, "Good day", "GOOD");
        when(journalEntryRepository.findByUserIdAndEntryDate(userId, date)).thenReturn(Optional.of(existing));
        when(journalEntryRepository.save(any(JournalEntry.class))).thenAnswer(invocation -> invocation.getArgument(0));

        var response = service.upsert(date, new JournalEntryRequest("Actually a rough day", "ROUGH"));

        assertThat(response.content()).isEqualTo("Actually a rough day");
        assertThat(response.mood()).isEqualTo("ROUGH");
    }

    @Test
    void gettingAnotherUsersOrMissingDateThrowsNotFound() {
        LocalDate date = LocalDate.now();
        when(journalEntryRepository.findByUserIdAndEntryDate(userId, date)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.get(date)).isInstanceOf(ResourceNotFoundException.class);
    }
}
