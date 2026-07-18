-- Milestone 1/2: users + refresh_tokens. UUID primary keys are generated in the application
-- layer (see BaseEntity), not by the database, so no pgcrypto/uuid-ossp extension is needed.

CREATE TABLE users (
    id                     UUID PRIMARY KEY,
    username               TEXT NOT NULL,
    email                  TEXT NOT NULL,
    password_hash          TEXT,
    profile_picture_url    TEXT,
    timezone               TEXT NOT NULL,
    country                TEXT NOT NULL,
    language               TEXT NOT NULL,
    dark_mode_preference   BOOLEAN NOT NULL DEFAULT TRUE,
    bio                    TEXT,
    level                  INTEGER NOT NULL DEFAULT 1,
    xp                     BIGINT NOT NULL DEFAULT 0,
    member_since           TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at             TIMESTAMPTZ,
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT uq_users_username UNIQUE (username)
);

CREATE TABLE refresh_tokens (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash  TEXT NOT NULL,
    expires_at  TIMESTAMPTZ NOT NULL,
    revoked     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at  TIMESTAMPTZ,
    CONSTRAINT uq_refresh_tokens_token_hash UNIQUE (token_hash)
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens (user_id);
