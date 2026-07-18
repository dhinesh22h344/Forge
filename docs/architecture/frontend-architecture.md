# Flutter Architecture

## Layers (Clean Architecture)

```
presentation  →  domain  →  data
```

- **presentation/** — Widgets, screens, Riverpod `Notifier`/`AsyncNotifier` classes. Only
  layer allowed to import Flutter Material widgets. Talks to `domain` only.
- **domain/** — Entities (plain Dart classes, no JSON/Freezed annotations), repository
  *interfaces* (abstract classes), use cases (single-purpose classes with one `call()`
  method, e.g. `CompleteHabitUseCase`). Zero dependency on Flutter or any package other
  than pure Dart — this layer is what makes business logic testable without widgets.
- **data/** — Repository *implementations*, remote data sources (Dio/Retrofit-style API
  clients generated from `docs/api/openapi.yaml`), local data sources (Drift/Isar for
  offline-first), DTOs + mappers to/from domain entities.

Dependency rule: **outer layers depend inward, never the reverse.** `domain` never imports
from `data` or `presentation`. This is what lets offline sync (M10) swap a local data
source in without touching a single screen.

## Folder Structure — feature-first

```
mobile/lib/
├── core/
│   ├── theme/            # ThemeData builders for all 10 themes, design tokens
│   ├── router/            # GoRouter config, route guards (auth redirect)
│   ├── network/            # Dio client, interceptors (JWT attach, refresh, retry)
│   ├── storage/            # Secure storage, local DB (Drift) bootstrap
│   ├── error/              # Failure types, exception → Failure mapping
│   ├── di/                 # Riverpod provider overrides / bootstrapping
│   └── widgets/            # Truly shared components (buttons, cards, empty states)
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   ├── domain/
│   │   └── data/
│   ├── dashboard/
│   ├── categories/
│   ├── habits/
│   ├── tracking/
│   ├── reports/
│   ├── achievements/
│   ├── journal/
│   ├── profile/
│   ├── notifications/
│   └── search/
└── main.dart
```

**Why feature-first over layer-first** (`lib/presentation/`, `lib/domain/`, `lib/data/` at
the root): Forge has 11+ features, each shipped in its own milestone. Feature-first means
Milestone 5 (Habits) touches exactly one top-level folder, PRs stay scoped, and a feature
can be deleted or feature-flagged by deleting one directory. Layer-first is better for
small apps with 2-3 screens where cross-feature layer consistency matters more than
feature isolation — that's not Forge.

## State Management: Riverpod

- `AsyncNotifierProvider` for anything backed by a repository call (habits list, dashboard
  widgets, reports) — gives loading/error/data states for free, which maps directly to the
  required loading/error/empty states per screen.
- `NotifierProvider` for pure client-side state (theme selection, widget drag-reorder
  in-progress state before persisting).
- Providers are scoped per-feature (`habitsListProvider` lives in
  `features/habits/presentation/providers/`), not one global provider file — keeps the
  dependency graph legible as the app grows.
- **Why Riverpod over Bloc/Provider:** compile-time safety (no `BuildContext` needed to
  read providers), built-in `AsyncValue` for the loading/error/data pattern used
  everywhere in this spec, and testability (override providers in tests without a widget
  tree).

## Navigation: GoRouter

- Declarative route tree in `core/router/`, with a `redirect` guard checking auth state
  (JWT presence + validity) before allowing access to any route under `/app/*`.
- Deep-link ready from day one (needed later for notification taps → habit detail).
- Nested navigation: bottom nav (`Dashboard`, `Habits`, `Reports`, `Achievements`, `Profile`) uses
  `StatefulShellRoute` so each tab keeps its own navigation stack.

## Offline-First Data Flow

Repository implementations in `data/` always read from the local DB first and write
through: UI never talks to the network directly.

```
UI → UseCase → Repository → LocalDataSource (source of truth for reads)
                          → RemoteDataSource (sync target, background)
```

A `SyncService` in `core/` watches connectivity (via `connectivity_plus`) and replays a
local outbox of pending mutations when connectivity returns. Full design happens in M10;
the seam (repository interface) is defined now so no feature built before M10 needs
rework.

## Responsive Design

Single codebase, three breakpoints (phone / tablet / — future: web/desktop) using
`LayoutBuilder` + a shared `Breakpoints` utility in `core/`. Dashboard grid and habit
list switch column count at breakpoints rather than having separate tablet screens.
