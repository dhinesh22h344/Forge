-- Phase 4: journal. One entry per user per calendar day (upsert semantics, like habit_logs).

CREATE TABLE journal_entries (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    entry_date  DATE NOT NULL,
    content     TEXT NOT NULL,
    mood        TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at  TIMESTAMPTZ,
    CONSTRAINT uq_journal_entries_user_date UNIQUE (user_id, entry_date),
    CONSTRAINT chk_journal_entries_mood CHECK (mood IS NULL OR mood IN ('GREAT', 'GOOD', 'OKAY', 'LOW', 'ROUGH'))
);

CREATE INDEX idx_journal_entries_user_date ON journal_entries (user_id, entry_date);
