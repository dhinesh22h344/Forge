package com.forge.journal.service;

import com.forge.common.exception.ResourceNotFoundException;
import com.forge.common.validation.SecurityUtils;
import com.forge.journal.dto.JournalEntryRequest;
import com.forge.journal.dto.JournalEntryResponse;
import com.forge.journal.entity.JournalEntry;
import com.forge.journal.repository.JournalEntryRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class JournalService {

    private final JournalEntryRepository journalEntryRepository;

    public JournalService(JournalEntryRepository journalEntryRepository) {
        this.journalEntryRepository = journalEntryRepository;
    }

    @Transactional(readOnly = true)
    public JournalEntryResponse get(LocalDate date) {
        UUID userId = SecurityUtils.getCurrentUserId();
        return journalEntryRepository
                .findByUserIdAndEntryDate(userId, date)
                .map(this::toResponse)
                .orElseThrow(() -> ResourceNotFoundException.of("JournalEntry", date));
    }

    @Transactional(readOnly = true)
    public List<JournalEntryResponse> list(LocalDate from, LocalDate to) {
        UUID userId = SecurityUtils.getCurrentUserId();
        List<JournalEntry> entries = (from == null || to == null)
                ? journalEntryRepository.findByUserIdOrderByEntryDateDesc(userId)
                : journalEntryRepository.findByUserIdAndEntryDateBetweenOrderByEntryDateDesc(userId, from, to);
        return entries.stream().map(this::toResponse).toList();
    }

    /** Upsert semantics: one entry per (user, date) — PUTting the same day again updates it. */
    public JournalEntryResponse upsert(LocalDate date, JournalEntryRequest request) {
        UUID userId = SecurityUtils.getCurrentUserId();
        JournalEntry entry = journalEntryRepository.findByUserIdAndEntryDate(userId, date).orElse(null);

        if (entry == null) {
            entry = new JournalEntry(userId, date, request.content(), request.mood());
        } else {
            entry.setContent(request.content());
            entry.setMood(request.mood());
        }
        entry = journalEntryRepository.save(entry);
        return toResponse(entry);
    }

    public void delete(LocalDate date) {
        UUID userId = SecurityUtils.getCurrentUserId();
        JournalEntry entry = journalEntryRepository
                .findByUserIdAndEntryDate(userId, date)
                .orElseThrow(() -> ResourceNotFoundException.of("JournalEntry", date));
        journalEntryRepository.delete(entry);
    }

    private JournalEntryResponse toResponse(JournalEntry entry) {
        return new JournalEntryResponse(
                entry.getId(), entry.getEntryDate(), entry.getContent(), entry.getMood(), entry.getCreatedAt(), entry.getUpdatedAt());
    }
}
