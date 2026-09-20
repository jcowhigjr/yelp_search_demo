# Review record - chore: remove merge-conflict debris and dead scaffolding

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-19 |
| Commit(s) reviewed | `f96af0a` |
| Reviewer | `claude/sonnet-5` |
| Invocation | `claude -p "<fresh-context, falsification-required review of the isolated chore/remove-conflict-debris diff>" --output-format json --allowedTools "Read,Glob,Grep,Bash(git diff:*),Bash(git log:*),Bash(git show:*),Bash(git grep:*),Bash(git status:*),Bash(mise:*),Bash(ls:*)"` |
| Requested by | jcowhigjr, via a Claude Code session auditing docs/rules/CI for low-value content |
| Authored the change? | no |
| Fresh context? | yes |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo |

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | medium | The commit message claimed a tree-wide grep for conflict markers found "none remain." False for this branch in isolation: `WARP.md` still carries the identical three-way Ruby-version conflict this commit cleans up in `Dockerfile` and `bin/setup-agent0`. Root cause: the grep was run and was genuinely clean at the time, but against a working tree that had *both* this commit and a sibling docs commit applied together, before the two were split into independent branches (`docs/dead-config-cleanup` fixes `WARP.md`). The verification claim went stale the moment the branches were split and was never re-checked against the isolated diff. | fixed: commit message amended to scope the claim to the four files this commit actually touches, name `WARP.md`'s fix as living in the sibling PR, and state plainly that this PR alone does not make the tree conflict-marker-free - the two PRs together do. |

## Disproved

| Candidate | Why it does not hold |
|-----------|----------------------|
| "Dockerfile still has conflict markers or is syntactically unsound." | `git grep` for conflict-marker patterns returns nothing in `Dockerfile`; `ARG` before `FROM` with interpolation is valid Docker syntax since 17.05. |
| "The resolved `RUBY_VERSION` (3.3.12) doesn't match mise.toml." | `mise.toml:12` sets `ruby = "3.3.12"` - exact match. |
| "No CI/deploy process actually needs this Dockerfile, so the claim it's unused is wrong." | `grep -rniE 'docker build|dockerfile' .github/workflows/` returns nothing; the repo deploys via Heroku (`Procfile`, `app.json`), no Docker path. |
| "`app/services/demo_service.rb` is referenced somewhere a literal grep would miss (dynamic `constantize`, reflection)." | Class uses plain Zeitwerk naming with no dynamic lookup; `git grep` for both the filename and class name across the full post-deletion tree returns zero hits. |
| "`bin/setup-agent0` has a sibling script that supersedes it, making deletion premature." | No `bin/setup-agent*` script exists post-deletion; no other reference anywhere. |
| "Removing `demo_service.rb` broke the test suite." | Re-ran `mise run test` post-deletion: `99 runs, 456 assertions, 0 failures, 0 errors, 0 skips` - matches the commit message's claimed figures exactly. |
| "`bin/setup-agent0`'s non-conflict line was fine." | Confirmed broken independent of the conflict: `ruby -v | awk {print }` - `awk` given no field argument, a pre-existing bug in the deleted file. |

## Not reviewed

- **`docs/dead-config-cleanup` was reviewed separately** (its own record covers `WARP.md`'s conflict resolution and the rest of the docs/rules batch). The two PRs are dependent in the narrow sense described above and should both be read to confirm the tree ends up clean; neither alone is the full picture.
- **The Dockerfile was not build-tested.** The local Docker daemon was not running in this environment. The file is syntactically ordinary; it was not exercised end-to-end.

## Verification

```
mise run test                              (isolated chore/remove-conflict-debris branch)
99 runs, 456 assertions, 0 failures, 0 errors, 0 skips

git grep -nE '^(<<<<<<<|=======|>>>>>>>)' Dockerfile bin/setup-agent0   (pre-deletion / post-resolution)
-> clean

git grep -n 'demo_service\|DemoService\|setup-agent\|lefthook.yml.backup' -- .   (post-commit, full tree)
-> no hits
```
