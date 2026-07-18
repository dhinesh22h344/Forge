package com.forge.auth.service;

import com.forge.auth.entity.RefreshToken;
import com.forge.auth.repository.RefreshTokenRepository;
import com.forge.common.exception.InvalidCredentialsException;
import com.forge.security.jwt.JwtProperties;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;
import org.springframework.stereotype.Service;

/**
 * Refresh tokens are opaque random strings, not JWTs — only their SHA-256 hash is ever stored
 * (see RefreshToken entity javadoc). Rotated on every use: the token presented is revoked and a
 * new one issued, so a stolen-but-unused-yet token becomes worthless the moment the legitimate
 * client refreshes again.
 */
@Service
public class RefreshTokenService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final RefreshTokenRepository repository;
    private final JwtProperties jwtProperties;

    public RefreshTokenService(RefreshTokenRepository repository, JwtProperties jwtProperties) {
        this.repository = repository;
        this.jwtProperties = jwtProperties;
    }

    public String issue(UUID userId) {
        String rawToken = generateRawToken();
        RefreshToken entity = new RefreshToken(userId, hash(rawToken), Instant.now().plus(jwtProperties.refreshTokenTtl()));
        repository.save(entity);
        return rawToken;
    }

    /** Validates, revokes the presented token, and issues a replacement in one step. */
    public RotationResult rotate(String rawToken) {
        RefreshToken existing = repository
                .findByTokenHash(hash(rawToken))
                .filter(RefreshToken::isValid)
                .orElseThrow(() -> new InvalidCredentialsException("Refresh token is invalid or expired"));
        existing.revoke();
        String newRawToken = issue(existing.getUserId());
        return new RotationResult(existing.getUserId(), newRawToken);
    }

    public void revoke(String rawToken) {
        repository.findByTokenHash(hash(rawToken)).ifPresent(RefreshToken::revoke);
    }

    /** Signs the user out of every device — used on password change and account deletion. */
    public void revokeAllForUser(UUID userId) {
        repository.findByUserIdAndRevokedFalse(userId).forEach(RefreshToken::revoke);
    }

    private String generateRawToken() {
        byte[] bytes = new byte[48];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hash(String rawToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return Base64.getEncoder().encodeToString(digest.digest(rawToken.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }

    public record RotationResult(UUID userId, String rawToken) {}
}
