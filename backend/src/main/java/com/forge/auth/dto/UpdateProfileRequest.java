package com.forge.auth.dto;

import jakarta.validation.constraints.Size;

/** All fields optional — PATCH semantics, only non-null fields are applied. */
public record UpdateProfileRequest(
        String profilePictureUrl,
        String timezone,
        String country,
        String language,
        Boolean darkModePreference,
        @Size(max = 140) String bio) {}
