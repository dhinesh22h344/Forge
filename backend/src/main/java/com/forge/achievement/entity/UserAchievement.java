package com.forge.achievement.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

/**
 * Not a {@code BaseEntity} — an unlock is a permanent fact about history, never soft-deleted or
 * updated. `unique(user_id, achievement_code)` at the DB layer is what makes evaluation
 * idempotent (see AchievementService#evaluateForUser).
 */
@Entity
@Table(name = "user_achievements")
@EntityListeners(AuditingEntityListener.class)
public class UserAchievement {

    @Id
    @Column(nullable = false, updatable = false)
    private UUID id = UUID.randomUUID();

    @Column(name = "user_id", nullable = false, updatable = false)
    private UUID userId;

    @Column(name = "achievement_code", nullable = false, updatable = false)
    private String achievementCode;

    @CreatedDate
    @Column(name = "unlocked_at", nullable = false, updatable = false)
    private Instant unlockedAt;

    protected UserAchievement() {}

    public UserAchievement(UUID userId, String achievementCode) {
        this.userId = userId;
        this.achievementCode = achievementCode;
    }

    public UUID getId() {
        return id;
    }

    public UUID getUserId() {
        return userId;
    }

    public String getAchievementCode() {
        return achievementCode;
    }

    public Instant getUnlockedAt() {
        return unlockedAt;
    }
}
