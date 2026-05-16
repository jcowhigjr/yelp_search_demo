## Context

This Rails 8.1 app already persists searches, favorites, reviews, and users. The change adds a small durable product-event table so those existing behaviors can be queried as local outcome signals. The implementation must remain Rails-native and avoid external analytics dependencies.

## Goals / Non-Goals

**Goals:**

- Capture intentional user-action outcome events at search, favorite, review, and return-visit boundaries.
- Keep event payloads compact, non-secret, and app-owned.
- Provide a local rake summary for the first useful signal metrics.
- Preserve existing user-facing behavior.

**Non-Goals:**

- No external analytics vendor, dashboard, or warehouse integration.
- No automatic GitHub issue creation from thresholds.
- No background job system or async delivery requirement.
- No broad model callback/concern that records every persistence change.

## Decisions

- Use an `OutcomeEvent` Active Record model backed by the app database as the durable v1 store. This keeps reporting queryable without adding infrastructure.
- Use a tiny explicit `OutcomeEvents.record(...)` service at user-action boundaries. This keeps controller instrumentation readable and avoids broad callbacks.
- Event type values are validated by the model against a fixed allowlist: `search_success`, `search_error`, `favorite_added`, `review_left`, and `return_visit`.
- Payloads are stored as JSON-compatible data and limited to safe identifiers/context such as query, search id, coffeeshop id, rating, and error category.
- The rake task reads `OutcomeEvent` rows and prints a plain-text summary. Blazer, Ahoy, Solid Queue, and external analytics remain later options, not part of this change.

## Risks / Trade-offs

- Synchronous recording can fail in the request path -> centralize event creation in a small service and keep it simple.
- Payload shape can drift -> use tests for each event producer and keep payloads minimal.
- SQLite/Postgres JSON support differs -> use Rails serialization/JSON-compatible column behavior that works in the current database setup.
- Metrics may be approximate in v1 -> report simple counts/rates first and avoid automated product decisions.

## Migration Plan

- Add the table through a normal Rails migration.
- Deploy with no backfill; events begin accumulating after release.
- Rollback by reverting the migration and instrumentation.

## Open Questions

None for v1.
