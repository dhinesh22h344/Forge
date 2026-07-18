package com.forge.journal.entity;

import com.forge.common.audit.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

/**
 * One entry per user per calendar day — a note, not an event log, so unlike {@code HabitLog} it
 * extends {@link BaseEntity} and is soft-deletable. `unique(user_id, entry_date)` makes PUTting
 * the same day idempotent (upsert), same pattern as HabitLog for (habit_id, log_date).
 */
@Entity
@Table(name = "journal_entries")
@SQLDelete(sql = "UPDATE journal_entries SET deleted_at = now() WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
public class JournalEntry extends BaseEntity {

    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;

    @Column(name = "entry_date", nullable = false, updatable = false)
    private LocalDate entryDate;

    @Column(nullable = false)
    private String content;

    @Column
    private String mood;

    protected JournalEntry() {}

    public JournalEntry(UUID userId, LocalDate entryDate, String content, String mood) {
        this.userId = userId;
        this.entryDate = entryDate;
        this.content = content;
        this.mood = mood;
    }

    public UUID getUserId() {
        return userId;
    }

    public LocalDate getEntryDate() {
        return entryDate;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getMood() {
        return mood;
    }

    public void setMood(String mood) {
        this.mood = mood;
    }
}
