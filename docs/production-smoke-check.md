# Production Smoke Check

> Addresses [issue #1848](https://github.com/jcowhigjr/yelp_search_demo/issues/1848)

## What it is

A lightweight GitHub Actions workflow (`.github/workflows/production-smoke-check.yml`) that
runs automatically after every merge to `develop` and verifies the live production app at
**<https://dorkbob.herokuapp.com/>** is actually serving the latest deployed code.

## Why it exists

Repo-local tests and preview-environment verification are not enough to prove that production
matches the merged code.  A PR can look green while Heroku is still serving an older build or
a failed deploy went unnoticed.  This check closes that gap.

## When it runs

| Trigger | When |
|---------|------|
| Automatic | Every `push` to the `develop` branch (the production-tracking branch) |
| Manual | Via **Actions → Production Smoke Check → Run workflow** at any time |

## What it checks

| Step | URL | Assertion | What it proves |
|------|-----|-----------|----------------|
| Health endpoint | `/healthz` | HTTP 200, body `OK` | Rails app is running and the database is reachable |
| Root page DOM marker | `/` | HTTP 200, HTML contains `search-hero-page` | Rails routing is working and the search home view is rendering |

Both checks use only public HTTP — **no private Heroku credentials are required**.

The workflow waits 90 seconds after the push before checking, to allow Heroku time to deploy.

## What happens on failure

1. **The workflow exits non-zero** — the commit/branch shows a red check in GitHub, blocking
   any subsequent auto-merge flows.
2. **A GitHub issue is opened automatically** with the commit SHA, a link to the failing run,
   and a description of which assertion failed.  This ensures drift is never silent even when
   no one is watching the Actions tab.

## How to interpret a failure

- **`/healthz` returns non-200 or non-`OK` body** — the Heroku dyno may be crashed, the
  database may be down, or the deploy may have failed entirely.  Check the Heroku dashboard
  and activity log.
- **Root page missing `search-hero-page` marker** — the app responded but the expected view
  is not rendering.  This could mean a stale asset cache, a failed asset pipeline build, or
  that the wrong code revision was deployed.

## Extending the checks

To add a stronger provenance marker (e.g. embed the git SHA in a `<meta>` tag):

1. Add `<meta name="x-app-version" content="<%= Rails.application.config.app_version %>">`
   to `app/views/layouts/application.html.erb`.
2. Set `config.app_version = ENV.fetch('HEROKU_SLUG_COMMIT', 'unknown')` in
   `config/application.rb`.
3. Update the root-page check step to `grep` for the expected commit SHA.
