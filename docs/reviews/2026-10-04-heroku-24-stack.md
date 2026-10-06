# Review record - bugfix/issue-3037-heroku-24-stack

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-10-04 |
| Commit(s) reviewed | `c616708094d07d3617e143fad012b15959207bee` (range `6445996b7c70dda6f2a60f77b386ebec42c00ef5..c616708094d07d3617e143fad012b15959207bee`) |
| Reviewer | `claude/opus` (self-check by the authoring session, not an independent review) |
| Invocation | Claude Code subagent session that authored the change; it read `app.json`, `mise.toml`, `Gemfile`, `Gemfile.lock`, `Dockerfile`, `Procfile` and grepped the repo for other stack references |
| Requested by | repository owner, via a delegating Claude Code session for issue #3037 |
| Authored the change? | yes |
| Fresh context? | no - the same session wrote the change |
| Independent? | no |
| Escalated to human? | yes - no independent reviewer ran, and the heroku-24 stack has not been verified on a real Heroku build (no review app or staging build was created, and `heroku stack:set` on `dorkbob` is a production change that needs human approval) |
| Given | full repo |

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|

## Not reviewed

- An actual Heroku build on heroku-24 (review app, staging, or `dorkbob`). Native gems such as `pg` (compiled from source against libpq) and the `nokogiri`/`ffi` `x86_64-linux-gnu` precompiled gems were checked only by reading `Gemfile.lock`, not by building on Ubuntu 24.04.
- Production behaviour after the stack change; the smoke check in `docs/production-smoke-check.md` has not been run against a heroku-24 slug.
- The `Dockerfile` is based on the Debian `ruby:3.3.12` image and does not use the Heroku stack, so it was left unchanged.

## Verification

```
grep -rnIE "heroku-2[0-9]|22\.04|24\.04|jammy|noble" (excluding vendor/tmp/log/node_modules/.git)
app.json:24:  "stack": "heroku-22",   (before the change; only reference in the repo)

heroku stack -a dorkbob   (read-only)
* heroku-22  (current); heroku-24 and heroku-26 available

heroku buildpacks -a dorkbob   (read-only)
heroku/ruby

python3 -m json.tool app.json
valid JSON

mise run test
101 runs, 467 assertions, 0 failures, 0 errors, 0 skips
```
