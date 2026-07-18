package com.forge.furnace.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

/**
 * One row per successful reforge — the only state The Furnace needs to persist. Eligibility
 * (is there an active ember, is the 30-day cooldown clear) is derived on read from this table
 * plus habit_logs, same spirit as {@link com.forge.habitlog.service.StreakService}.
 */
@Entity
@Table(name = "habit_streak_recoveries")
@EntityListeners(AuditingEntityListener.class)
public class HabitStreakRecovery {

    @Id
    @Column(nullable = false, updatable = false)
    private UUID id = UUID.randomUUID();

    @Column(name = "habit_id", nullable = false, updatable = false)
    private UUID habitId;

    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;

    @Column(name = "recovered_date", nullable = false, updatable = false)
    private LocalDate recoveredDate;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected HabitStreakRecovery() {}

    public HabitStreakRecovery(UUID habitId, UUID userId, LocalDate recoveredDate) {
        this.habitId = habitId;
        this.userId = userId;
        this.recoveredDate = recoveredDate;
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

    public LocalDate getRecoveredDate() {
        return recoveredDate;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
