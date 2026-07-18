-- Milestone 6: tracking. No deleted_at — see HabitLog entity javadoc.

CREATE TABLE habit_logs (
    id              UUID PRIMARY KEY,
    habit_id        UUID NOT NULL REFERENCES habits (id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    log_date        DATE NOT NULL,
    status          TEXT NOT NULL,
    progress_value  NUMERIC(10, 2),
    notes           TEXT,
    completed_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_habit_logs_habit_date UNIQUE (habit_id, log_date),
    CONSTRAINT chk_habit_logs_status CHECK (status IN ('COMPLETED', 'MISSED', 'SKIPPED'))
);

CREATE INDEX idx_habit_logs_user_date ON habit_logs (user_id, log_date);
CREATE INDEX idx_habit_logs_habit_date ON habit_logs (habit_id, log_date);
