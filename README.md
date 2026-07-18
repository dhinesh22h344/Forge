# Forge

A Personal Operating System — not a habit tracker. Users build their own lifestyle
system from scratch: categories, habits, tracking, reports, achievements, all
user-defined, nothing pre-seeded.

## Docs

- [`docs/architecture/product-spec.md`](docs/architecture/product-spec.md) — vision, module scope, user flow, screen inventory
- [`docs/architecture/repo-strategy.md`](docs/architecture/repo-strategy.md) — monorepo decision and layout
- [`docs/architecture/frontend-architecture.md`](docs/architecture/frontend-architecture.md) — Flutter Clean Architecture, state management, navigation
- [`docs/architecture/backend-architecture.md`](docs/architecture/backend-architecture.md) — Spring Boot layered architecture, security, package structure
- [`docs/architecture/database-schema.md`](docs/architecture/database-schema.md) — PostgreSQL ER diagram, tables, indexes, constraints
- [`docs/api/openapi.yaml`](docs/api/openapi.yaml) — API contract skeleton (design-first)

## Status

Milestones 1-3 done and verified end-to-end (real device against a live backend):
- **M1 Project Setup** — Flutter app (`mobile/`) and Spring Boot app (`backend/`) scaffolded per the architecture docs, Postgres via `docker/docker-compose.yml`, Flyway migrations, CI in `.github/workflows/`.
- **M2 Authentication** — register/login/refresh/logout with JWT, BCrypt, Spring Security; splash → onboarding → register → create-profile flow in Flutter. Firebase-based `/auth/session` is documented in `docs/api/openapi.yaml` but not wired — needs a Firebase project the product owner provisions.
- **M3 Dashboard** — customizable widget list (drag to reorder, hide/show, persisted server-side), full empty states since no habits exist yet.

### Running locally
- Backend: `cd backend && ./gradlew bootRun` (needs Postgres — `brew services start postgresql@16` or `docker compose -f docker/docker-compose.yml up -d postgres`)
- Mobile: `cd mobile && flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1` (Android emulator; use your host IP or `http://localhost:8080/api/v1` for iOS simulator/desktop)

Next: Milestone 4 (Categories).

## Stack

Flutter (Riverpod, GoRouter, Material 3) · Spring Boot (Java 21, Spring Security, JWT) ·
PostgreSQL · Firebase Auth/FCM · Docker · GitHub Actions.
