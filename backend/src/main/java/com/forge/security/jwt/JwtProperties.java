package com.forge.security.jwt;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

/** Bound from `forge.jwt.*` in application.yml — see that file for local defaults. */
@ConfigurationProperties(prefix = "forge.jwt")
public record JwtProperties(String secret, Duration accessTokenTtl, Duration refreshTokenTtl) {}
