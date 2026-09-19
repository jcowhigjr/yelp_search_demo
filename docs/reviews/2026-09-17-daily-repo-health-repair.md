# Review record - repair Daily Repo Health sweep and bound auto-merge state recheck

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-17 |
| Commit(s) reviewed | `a149f43`, `f77044d`, `a031d7d`, `4214e76` (branch `bugfix/issue-3003-daily-repo-health`) |
| Reviewer | devin subagent (subagent_explore) / SWE-2 |
| Invocation | `run_subagent` with the diff range `origin/develop...HEAD`, the changed-file list, and instructions to disprove each candidate finding before reporting it |
| Requested by | devin (authoring agent), per Route B in docs/AGENTS.md after `claude` CLI returned 401 (OAuth revoked) and `codex` CLI hit its usage limit |
| Authored the change? | no |
| Fresh context? | yes - the reviewer saw only the repository state and the changed-file list, not the authoring session's reasoning |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo - reviewer read the complete files plus sibling workflows, docs/AGENTS.md, docs/dependabot-automerge-fix.md, and test_helper.rb |

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | medium | `daily-repo-health.yml` omitted `actions: read`; `gh run list` hits the Actions API and unlisted scopes become `none`, so checks 3-4 could 403 on a private repo | fixed in `a031d7d` |
| 2 | medium | `auto-update-prs.sh` consumed `gh pr list \| jq` via process substitution, whose producer exit status never propagates; a failed list read as "No open PRs behind develop" | fixed in `a031d7d` - output is captured first, so `set -e` aborts on failure |
| 3 | low | The fake-gh `--jq` validator treats bare args after the expression as errors, which would false-positive if future code put flags after `--jq` | declined - dormant today (no `--jq` in the scripts); documented in the fixture header |
| 4 | low | `gh pr merge` / `gh workflow run` omitted `--repo "$REPO"` unlike every other call | fixed in `a031d7d` |
| 5 | low | `gh pr list` had no `--limit` (defaults to 30) | fixed in `a031d7d` - now `--limit 50` |
| 6 | low | No coverage for the fail-loud contract, the head-SHA timeout, or update-branch failure; no test pinned the workflow-to-script wiring | partially fixed in `a031d7d` - stubs inject failures and new tests cover a dead `gh`, a dead `pr list`, a failed `update-branch`, and the workflow wiring |
| 7 | low | `teardown_gh_stub` raised a second error if setup died before `@dir` was set | fixed in `a031d7d` |
| 8 | info | `jq` was not pinned in mise.toml though the new scripts and tests need it | fixed in `a031d7d` - `jq = "1.8.2"` |

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| `actions/checkout@v7` might be invalid | All 12 repo workflows use `@v7`; it is the established convention |
| `set -uo pipefail` in workflow run blocks drops `-e` | GitHub runs steps via `bash -e -o pipefail`; `set` does not clear it |
| `--jq '.[0].number // ""'` in the tracking-issue step repeats the original bug | It is a single expression with no extra positional args; legitimate `--jq` usage |
| Empty-array expansion under `set -u` | All arrays are guarded by `${#arr[@]} -gt 0` before expansion |
| `UNRESOLVED` increment tripping `set -e` | Uses `UNRESOLVED=$((UNRESOLVED + 1))`, not `((var++))` |
| `read` in the recheck loop swallows a failed `gh pr view` | `read` hits EOF and returns non-zero; `set -e` exits loudly |
| Re-running `gh pr merge --auto` on a queued PR errors | docs/dependabot-automerge-fix.md confirms update-branch clears the request, so restore is required |
| `gh workflow run main.yml` targets nonexistent inputs | `main.yml` declares `triggered_by` and `pr_number` workflow_dispatch inputs |
| `--author "dependabot[bot]"` is wrong | Same invocation exists in `dependabot-refresh.yml` |
| `GhStubHelpers` never loaded | `test/test_helper.rb` requires `test/support/**/*.rb` |
| New scripts missing the executable bit | Both are invoked as `bash scripts/...`; mode is irrelevant (they are also `chmod +x`) |
| TSV field corruption via `IFS=$'\t' read` | jq `@tsv` escapes tabs/newlines; ref names cannot contain literal tabs |
| `mergeStateStatus` null in the TSV | `@tsv` emits an empty field; treated as non-BEHIND/non-queued, safe either way |
| Stub `pr view` dispatch misfires on the head-SHA poll | The poll requests only `--json headRefOid`, which lacks the `mergeStateStatus` substring |
| `pr()` helper mixing string/symbol keys | `**fields` captures string-keyed overrides and `.merge` applies them |

## Not reviewed

Runtime behavior against the real GitHub API beyond the two dispatched runs; system/browser surfaces (no UI changed); the merged-state behavior of `gh pr merge --auto` on GitHub's side is trusted per docs/dependabot-automerge-fix.md rather than re-verified live.

## Verification

```
bin/rails test test/scripts/ test/integration/dependabot_workflow_configuration_test.rb
18 runs, 147 assertions, 0 failures, 0 errors

bundle exec rubocop (touched files)
5 files inspected, no offenses detected

shellcheck scripts/daily-repo-health-findings.sh scripts/auto-update-prs.sh test/fixtures/files/fake_gh_*.sh
clean

gh workflow run daily-repo-health.yml --ref bugfix/issue-3003-daily-repo-health
run 35228998040 - success; detected aging Dependabot PR #3013, commented on issue #3003

gh workflow run auto-update-prs.yml --ref bugfix/issue-3003-daily-repo-health
run 35229029753 - success; "No open PRs behind develop."
```
