package com.forge.journal.repository;

import com.forge.journal.entity.JournalEntry;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface JournalEntryRepository extends JpaRepository<JournalEntry, UUID> {

    Optional<JournalEntry> findByUserIdAndEntryDate(UUID userId, LocalDate entryDate);

    List<JournalEntry> findByUserIdAndEntryDateBetweenOrderByEntryDateDesc(UUID userId, LocalDate start, LocalDate end);

    List<JournalEntry> findByUserIdOrderByEntryDateDesc(UUID userId);
}
