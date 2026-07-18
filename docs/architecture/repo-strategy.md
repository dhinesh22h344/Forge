# Repo Strategy

## Decision: Monorepo

```
Forge/
├── mobile/                  # Flutter app (Android, iOS, tablet, web-future)
├── backend/                 # Spring Boot API
├── docs/                    # Architecture, API contracts, ERDs, ADRs
│   ├── architecture/
│   └── api/
├── docker/                  # docker-compose.yml, Dockerfiles, local Postgres/Redis
├── .github/
│   └── workflows/           # CI/CD pipelines (path-filtered per app)
└── README.md
```

## Why monorepo, not multi-repo

Forge's frontend and backend evolve in lockstep during the early build: every milestone
(Categories, Habits, Tracking, ...) touches the API contract *and* the Flutter client in
the same unit of work. A monorepo means:

- **One PR per feature** spans `mobile/` and `backend/` together — no cross-repo version
  pinning, no "which backend commit does this app build expect" drift.
- **Single source of truth for the contract** — `docs/api/openapi.yaml` lives next to both
  consumers, and the OpenAPI-generated Dart client can be regenerated in the same PR that
  changes a controller.
- **One CI pipeline, path-filtered** — GitHub Actions runs the Flutter job only when
  `mobile/**` changes and the Spring Boot job only when `backend/**` changes, so the cost
  of a monorepo (mixed toolchains) is paid only when relevant.
- **Single issue tracker / project board** — milestones map 1:1 to GitHub Projects columns
  without needing to correlate two repos.

**Trade-off accepted:** CI matrix is slightly more complex (Dart + Java in one repo), and
`git clone` pulls both apps even if a contributor only touches one. At solo/small-team
scale this is far cheaper than the coordination overhead of keeping two repos in sync on
every API change.

**Revisit when:** the team grows to multiple independent squads owning frontend vs.
backend, or the backend needs to serve a second, unrelated client — at that point, split
`backend/` out and publish the OpenAPI spec as the sole integration point.
