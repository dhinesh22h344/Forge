package com.forge.auth.dto;

import java.time.Instant;
import java.util.UUID;

public record UserResponse(
        UUID id,
        String username,
        String email,
        String profilePictureUrl,
        String timezone,
        String country,
        String language,
        boolean darkModePreference,
        String bio,
        int level,
        long xp,
        int currentStreak,
        int bestStreak,
        Instant memberSince) {}
