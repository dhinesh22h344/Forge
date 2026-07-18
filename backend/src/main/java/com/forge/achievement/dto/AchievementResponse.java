package com.forge.achievement.dto;

import java.time.Instant;

/** See docs/api/openapi.yaml `/achievements`. `title`/`description`/`icon` are masked when the
 * achievement is hidden and not yet unlocked — the client never learns what a hidden
 * achievement is until it's earned. */
public record AchievementResponse(
        String code, String title, String description, String icon, boolean hidden, boolean unlocked, Instant unlockedAt) {}
