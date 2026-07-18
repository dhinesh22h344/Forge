-- Milestone 5: habits + reminders. tags/folder are plain columns, not
-- relational tables — see Habit entity javadoc for why.

CREATE TABLE habits (
    id                       UUID PRIMARY KEY,
    user_id                  UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    category_id              UUID NOT NULL REFERENCES categories (id),
    name                     TEXT NOT NULL,
    description              TEXT,
    icon                     TEXT,
    emoji                    TEXT,
    image_url                TEXT,
    priority                 SMALLINT NOT NULL DEFAULT 2,
    difficulty               SMALLINT NOT NULL DEFAULT 3,
    repeat_type              TEXT NOT NULL,
    repeat_config            TEXT,
    goal_value               NUMERIC(10, 2),
    goal_unit                TEXT,
    estimated_time_minutes   INTEGER,
    color                    TEXT NOT NULL,
    gradient                 TEXT,
    start_date               DATE NOT NULL,
    end_date                 DATE,
    notes                    TEXT,
    tags                     TEXT[] NOT NULL DEFAULT '{}',
    folder                   TEXT,
    status                   TEXT NOT NULL DEFAULT 'ACTIVE',
    is_archived              BOOLEAN NOT NULL DEFAULT FALSE,
    created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at               TIMESTAMPTZ,
    CONSTRAINT chk_habits_priority CHECK (priority BETWEEN 1 AND 3),
    CONSTRAINT chk_habits_difficulty CHECK (difficulty BETWEEN 1 AND 5)
);

CREATE INDEX idx_habits_user_id ON habits (user_id);
CREATE INDEX idx_habits_user_category ON habits (user_id, category_id);
CREATE INDEX idx_habits_user_archived ON habits (user_id, is_archived);

CREATE TABLE habit_reminders (
    id           UUID PRIMARY KEY,
    habit_id     UUID NOT NULL REFERENCES habits (id) ON DELETE CASCADE,
    local_time   TIME NOT NULL,
    days_of_week TEXT[] NOT NULL DEFAULT '{}',
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at   TIMESTAMPTZ
);

CREATE INDEX idx_habit_reminders_habit_id ON habit_reminders (habit_id);
