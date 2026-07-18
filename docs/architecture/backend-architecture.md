# Spring Boot Architecture

## Layers

```
Controller → Service → Repository → Entity (JPA)
                ↑
              DTO/Mapper at the boundary (Controller ⇄ Service)
```

- **Controller** — `@RestController`, request mapping, `@Valid` on request DTOs, delegates
  to Service, never touches entities or the persistence layer directly.
- **Service** — business logic, transaction boundaries (`@Transactional`), orchestrates
  repositories, throws domain exceptions (`HabitNotFoundException`, etc.) that the global
  handler translates to HTTP responses.
- **Repository** — Spring Data JPA interfaces, one per aggregate root. Custom queries via
  `@Query` or QueryDSL for reporting aggregations.
- **Entity** — JPA entities, never returned directly from a controller (always mapped to a
  DTO) so the wire format can evolve independently of the schema.

## Package Structure — package-by-feature

```
backend/src/main/java/com/forge/
├── auth/
│   ├── controller/  service/  repository/  dto/  entity/  mapper/
├── user/
├── category/
├── habit/
├── habitlog/
├── streak/
├── reminder/
├── achievement/
├── report/
├── journal/
├── notification/
├── exportimport/
├── common/
│   ├── audit/          # BaseEntity (id, createdAt, updatedAt, deletedAt)
│   ├── exception/       # GlobalExceptionHandler, error response schema
│   ├── validation/      # custom validators
│   └── pagination/      # shared PageResponse<T> wrapper
├── config/
│   ├── SecurityConfig, OpenApiConfig, JacksonConfig, WebConfig
└── security/
    ├── jwt/             # JwtTokenProvider, JwtAuthFilter
    └── firebase/         # Firebase Admin SDK verification (email auth handoff)
```

**Why package-by-feature over package-by-layer** (`controller/`, `service/`,
`repository/` at the root): same reasoning as the Flutter side — 12+ backend modules
mapped 1:1 to milestones, and package-by-feature keeps a milestone's backend work inside
one package. Package-by-layer forces every feature's controller into the same folder as
every other feature's controller, which doesn't scale past ~5 resources.

## Security Architecture

- **Firebase Authentication** issues the identity (email/password now; Google/Apple
  providers are additive later since Firebase abstracts the provider). On successful
  Firebase sign-in, the client exchanges the Firebase ID token for a **Forge-issued JWT**
  at `POST /api/v1/auth/session` — the backend verifies the Firebase token server-side via
  Firebase Admin SDK, upserts the local `users` row, and mints an access + refresh token
  pair. This keeps authorization (roles, resource ownership) entirely in Forge's own JWT
  rather than trusting Firebase claims for backend authz decisions.
- `JwtAuthFilter` (a `OncePerRequestFilter`) validates the bearer token on every request,
  populates `SecurityContext` with the user id + roles.
- `SecurityConfig` — stateless session policy, method-level `@PreAuthorize` for
  role-based checks, CORS restricted to known origins, CSRF disabled (token-based API).
- Refresh tokens are stored hashed in `refresh_tokens` table, rotated on use, revocable
  (needed for "log out all devices").

## Validation & Exception Handling

- Bean Validation (`jakarta.validation`) annotations on request DTOs; `@Valid` at
  controller boundary.
- `GlobalExceptionHandler` (`@RestControllerAdvice`) maps:
  - `MethodArgumentNotValidException` → `400` with field-level error list
  - Domain `*NotFoundException` → `404`
  - `AccessDeniedException` → `403`
  - Unhandled → `500` with a generic body (no stack trace leakage)
- Every error response follows one shape (`docs/api/openapi.yaml` `Error` schema):
  `{ timestamp, status, error, message, path, fieldErrors[] }`.

## Cross-cutting concerns

- **Auditing**: `BaseEntity` (`common/audit`) provides `id (UUID)`, `createdAt`,
  `updatedAt` via `@CreatedDate`/`@LastModifiedDate` (Spring Data JPA auditing),
  `deletedAt` for soft delete. All aggregate-root entities extend it.
- **Soft delete**: `@SQLDelete` + `@Where(clause = "deleted_at IS NULL")` per entity, so
  reads never need manual filtering and deletes never lose data (needed for export/backup
  history and undo).
- **OpenAPI/Swagger**: springdoc-openapi generates the live spec from annotated
  controllers; `docs/api/openapi.yaml` is the *design-first* contract checked in for the
  Flutter client generator, springdoc output is the *implementation* verification that
  the two stay in sync (contract test in M11 diffs them).

## Modules → Milestone mapping

Each `com.forge.<feature>` package is built in the milestone of the same name (M4
`category`, M5 `habit`, M6 `habitlog`/`streak`, M7 `report`, M8 `achievement`, M9
`reminder`/`notification`). `common` and `config` are built in M1/M2 and extended as
needed, never restructured.
