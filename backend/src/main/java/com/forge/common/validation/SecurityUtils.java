package com.forge.common.validation;

import java.util.UUID;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * Reads the authenticated user id out of the Spring Security context. {@link
 * com.forge.security.jwt.JwtAuthFilter} sets the principal name to the Forge user's UUID string
 * after validating the JWT — every feature service should read the current user through here
 * rather than touching SecurityContextHolder directly.
 */
public final class SecurityUtils {

    private SecurityUtils() {}

    public static UUID getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new IllegalStateException("No authenticated user in security context");
        }
        return UUID.fromString(authentication.getName());
    }
}
