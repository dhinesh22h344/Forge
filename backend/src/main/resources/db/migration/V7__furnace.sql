-- Phase 2 retention: The Furnace (non-punitive streak recovery). A missed scheduled day
-- doesn't break a streak outright — it becomes an "ember" the user can reforge (backdate to
-- COMPLETED) through the end of the following day. Only the recovery grants are persisted;
-- eligibility itself is still computed on read from habit_logs, same as streaks.

CREATE TABLE habit_streak_recoveries (
    id             UUID PRIMARY KEY,
    habit_id       UUID NOT NULL REFERENCES habits (id) ON DELETE CASCADE,
    user_id        UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    recovered_date DATE NOT NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Most-recent-first lookup per habit is how the 30-day reforge cooldown is enforced.
CREATE INDEX idx_habit_streak_recoveries_habit ON habit_streak_recoveries (habit_id, created_at DESC);
