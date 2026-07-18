package com.forge;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

/**
 * Loads the full application context (all beans wire up, Flyway migrations apply against the
 * Postgres instance from application.yml/env vars). Needs a real Postgres reachable at
 * DB_URL/DB_USERNAME/DB_PASSWORD — see docker/docker-compose.yml locally, or the `postgres`
 * service container in .github/workflows/ci-backend.yml.
 */
@SpringBootTest
class ForgeBackendApplicationTests {

    @Test
    void contextLoads() {}
}
