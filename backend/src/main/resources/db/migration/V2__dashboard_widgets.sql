-- Milestone 3: dashboard widget layout persistence.

CREATE TABLE dashboard_widgets (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    widget_type TEXT NOT NULL,
    position    INTEGER NOT NULL,
    is_visible  BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at  TIMESTAMPTZ
);

CREATE INDEX idx_dashboard_widgets_user_id ON dashboard_widgets (user_id);
