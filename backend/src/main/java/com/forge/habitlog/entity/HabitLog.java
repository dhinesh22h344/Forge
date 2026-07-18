package com.forge.habitlog.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

/**
 * Not a {@code BaseEntity} — logs are never soft-deleted (a completion or a miss is a fact about
 * history; deleting a habit cascades its logs away instead, see V5 migration).
 * `unique(habit_id, log_date)` at the DB layer is what makes POSTing the same day idempotent.
 */
@Entity
@Table(name = "habit_logs")
@EntityListeners(AuditingEntityListener.class)
public class HabitLog {

    @Id
    @Column(nullable = false, updatable = false)
    private UUID id = UUID.randomUUID();

    @Column(name = "habit_id", nullable = false, updatable = false)
    private UUID habitId;

    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;

    @Column(name = "log_date", nullable = false, updatable = false)
    private LocalDate logDate;

    @Column(nullable = false)
    private String status;

    @Column(name = "progress_value", precision = 10, scale = 2)
    private BigDecimal progressValue;

    @Column
    private String notes;

    @Column(name = "completed_at")
    private Instant completedAt;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    protected HabitLog() {}

    public HabitLog(UUID habitId, UUID userId, LocalDate logDate, String status, BigDecimal progressValue, String notes) {
        this.habitId = habitId;
        this.userId = userId;
        this.logDate = logDate;
        this.status = status;
        this.progressValue = progressValue;
        this.notes = notes;
        this.completedAt = "COMPLETED".equals(status) ? Instant.now() : null;
    }

    public UUID getId() {
        return id;
    }

    public UUID getHabitId() {
        return habitId;
    }

    public UUID getUserId() {
        return userId;
    }

    public LocalDate getLogDate() {
        return logDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.completedAt = "COMPLETED".equals(status) ? Instant.now() : null;
        this.status = status;
    }

    public BigDecimal getProgressValue() {
        return progressValue;
    }

    public void setProgressValue(BigDecimal progressValue) {
        this.progressValue = progressValue;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Instant getCompletedAt() {
        return completedAt;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
