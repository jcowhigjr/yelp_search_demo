## 1. Data Model

- [x] 1.1 Add a migration for `outcome_events` with user, event type, payload, timestamps, and query indexes.
- [x] 1.2 Add an `OutcomeEvent` model with event type allowlist validation and user association.

## 2. Event Recording

- [x] 2.1 Add focused tests for recording search success, search error, favorite creation, review creation, and return visit events.
- [x] 2.2 Implement a tiny explicit `OutcomeEvents.record(...)` service and wire it into the target user-action boundaries.

## 3. Reporting

- [x] 3.1 Add a failing test for a local outcome signal summary task, including empty-data behavior.
- [x] 3.2 Implement the rake task summary for search-to-favorite rate, average review rating, review count, and search error rate.

## 4. Verification and Delivery

- [x] 4.1 Run focused model/controller/task tests and the relevant existing search/favorite/review tests.
- [ ] 4.2 Run project verification required for PR handoff, then commit, push, open a PR linked to issue #2887, merge when checks allow, and close the issue.
