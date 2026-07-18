-- Milestone 8: achievements. The catalog itself (title/description/icon/hidden/criteria) is
-- static, defined in code (see com.forge.achievement.catalog.AchievementCode) — only which
-- codes a user has unlocked, and when, is persisted here.

CREATE TABLE user_achievements (
    id               UUID PRIMARY KEY,
    user_id          UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    achievement_code TEXT NOT NULL,
    unlocked_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_achievements_user_code UNIQUE (user_id, achievement_code)
);

CREATE INDEX idx_user_achievements_user ON user_achievements (user_id);
