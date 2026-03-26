# Incident Postmortem: develop Deploy Pipeline Blocked by `next_rails` 1.4.7

Issue: #1778

## Summary

On March 26, 2026, the `develop` branch received commit `45d21e9e` from merged PR #1761, a Dependabot lockfile-only update that moved `next_rails` from `1.4.6` to `1.4.7` and `sqlite3` from `2.9.1` to `2.9.2`.

The currently deployed Heroku app remained healthy, but the delivery path for the new `develop` head was blocked:

- PR `#1761` merged despite failing `test` and `test-next` checks.
- The merge commit on `develop` did not receive the normal `Ruby on Rails CI` push workflow run.
- Heroku then reported a failed automatic deployment for app `dorkbob`.

This was a delivery incident, not a full production outage.

## Impact

- `develop` could not be trusted as deployable after the merge.
- Heroku automatic deployment of the new head failed.
- Engineers could not tell from the Heroku alert alone whether the fault was app code, CI policy, or GitHub integration.

## Detection

- Heroku sent an automatic deployment failure notification for `dorkbob`.
- Follow-up inspection of GitHub Actions and PR checks showed that PR `#1761` had already failed in CI before merge.
- Direct health checks against `https://dorkbob.herokuapp.com/healthz` still returned `200 OK`, confirming the already-running deploy was healthy.

## Timeline

- 2026-03-26 00:01 UTC: PR `#1761` runs CI for the Dependabot update.
- 2026-03-26 00:03-00:04 UTC: `test-next` and `test` fail during boot/setup.
- 2026-03-26 00:01 UTC: PR `#1761` merges to `develop` as commit `45d21e9e`.
- 2026-03-26 afternoon/evening US Eastern: Heroku reports automatic deployment failure for `dorkbob`.
- 2026-03-26 22:14 UTC: health check against the live app still returns `OK`.

## Root Cause

`next_rails` `1.4.7` is incompatible with this repository's current setup.

The failure reproduced in GitHub Actions and locally with:

- `Bundler::GemRequireError: There was an error while trying to load the gem 'next_rails'`
- `LoadError: cannot load such file -- byebug`

The repo uses the `debug` gem and does not include `byebug`. `next_rails` `1.4.7` now attempts to require `byebug`, which causes boot/setup to fail before `db:prepare` or tests can run.

## Contributing Factors

1. Merge gating failed.
   PR `#1761` merged even though required test jobs were red.

2. Post-merge validation failed.
   The merge commit on `develop` did not receive the normal `Ruby on Rails CI` push workflow run, so there was no automatic verification step on the actual branch head.

3. Heroku alerting lacked context.
   Heroku reported the downstream build failure, but the alert did not distinguish between a broken app revision and a broken GitHub-to-Heroku delivery path.

## Resolution

The immediate remediation stages the smallest safe unblock:

- Pin `next_rails` back to `1.4.6`, the last known-good version for this repository.
- Prevent automatic patch/minor Dependabot bumps for `next_rails` until compatibility is manually validated.

## Follow-Up Actions

1. Investigate why branch protection allowed PR `#1761` to merge with failing `test` and `test-next` checks.
2. Investigate why the `develop` push workflow did not run for merge commit `45d21e9e`.
3. Revisit whether `next_rails` should remain in unattended Dependabot groups or require manual review.
4. Consider adding a dedicated CI smoke check that only boots the app and requires `next_rails`, so boot regressions fail earlier and more explicitly.
