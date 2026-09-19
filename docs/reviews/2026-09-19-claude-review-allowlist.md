# Review record - fix(ci): grant the Claude reviewer read-only git tools

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-19 |
| Commit(s) reviewed | `bf8c634` (range `bc81530..bf8c634`) |
| Reviewer | `claude/opus-5` |
| Invocation | `claude -p "<fresh-context falsification-required review of bf8c634>" --output-format json --allowedTools "Read,Glob,Grep,Bash(git diff:*),Bash(git log:*),Bash(git show:*),Bash(git status:*)"` |
| Requested by | jcowhigjr, via a Claude Code session working #3021 |
| Authored the change? | no |
| Fresh context? | yes |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo |

The reviewer ran 46 turns and recorded 7 permission denials; it had no network
and no `gh` access, so it could not read the failing Actions run log. That
limitation is material to finding 1 below and is why the author was able to
falsify it afterwards.

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | low | The removed `label_trigger`'s stated rationale was wrong. The comment said the trigger "needs the `labeled` pull_request type, which this workflow does not subscribe to", implying that adding `labeled` to `on:` would revive it. In claude-code-action v1 the label check is gated on `isIssuesEvent(context) && eventAction === "labeled"` (`src/github/validation/trigger.ts:38`), i.e. the `issues` webhook only — a PR label never reaches it under any subscription. A maintainer could have wasted time on the implied fix. | fixed in the commit carrying this record (comment rewritten to cite the real gate; the removal itself was already correct) |

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| **Reported by the reviewer as a surviving MEDIUM finding**: "`actions/checkout@v7` runs with default `fetch-depth: 1`, so `origin/develop` is never fetched as a remote-tracking ref; the action does no supplemental fetch (`prepare.ts` has none); therefore the prompt's recommended `git diff origin/develop...HEAD` fails with 'unknown revision' and the fix does not deliver PR-diff inspection." | Falsified by the failing run's own log, which the reviewer could not read. Actions run 35403586958 contains `* [new ref]   bc8153029330b36419f794c534a7349752c6a939 -> origin/develop` — `actions/checkout` creates the ref itself, because on an `issue_comment` event it checks out the default branch. The supporting claim is also false: the action does fetch, in `src/github/operations/branch.ts:206,214,315,333` and `src/github/operations/restore-config.ts:313`; the reviewer inspected only `prepare.ts`. `origin/develop` exists, so the recommended command resolves. |
| "Granting `Bash(git log:*)`/`Bash(git show:*)` lets an injected commenter dump secrets from git history into a public PR comment." | Raised and falsified by the reviewer itself: with a shallow checkout there is no historical commit object to read, so `git show <older-sha>` fails. Independently, the repo tracks no plaintext secrets — `/config/master.key` and `.env*` are gitignored and credentials are `.enc` ciphertext — and this workflow injects no `RAILS_MASTER_KEY`. |
| "`--allowedTools` syntax is wrong for claude-code-action v1." | Falsified against the action source, not just its docs: `allowedTools` is in `ACCUMULATING_FLAGS` and the merge does `.flatMap((v) => v.split(","))` (`base-action/src/parse-sdk-options.ts`), so the comma-separated quoted form parses and is additive to the action's defaults rather than replacing them. The parser also escapes `()` metachars deliberately, so `Bash(git diff:*)` is not mangled into a wider `Bash(*)` rule. |
| "Removing `label_trigger` could break an in-flight label-triggered review." | Nothing could have been in flight: the trigger was already unreachable for PR labels (see finding 1), so no qualifying webhook ever started this job via a label. |
| "The YAML is malformed." | `yaml.safe_load` parses the file; `claude_args` resolves to the expected single-line string and `label_trigger` is absent from the `with:` mapping. |

## Not reviewed

- **The `is_error: true` failure itself.** This change does not fix it and does not claim to. Its cause is undiagnosed: it did not reproduce locally under the exact CI tool configuration, and the action's sanitizer discards `api_error_status`, `result`, `stop_reason` and `terminal_reason`. Tracked in #3021.
- **Runtime behaviour of the changed workflow.** `issue_comment` always runs the workflow from the default branch, so this cannot be exercised until it is merged to `develop`. Verified after merge, not before.
- **Shallow-history edge case.** `origin/develop` exists, but both it and the PR branch are fetched shallow (depth 1 and 20). A three-dot `git diff origin/develop...HEAD` needs a computable merge base, which shallow history can defeat on long-running branches. Not observed, not tested; noted as a follow-up rather than pre-emptively fixed, to keep this diff to its approved scope.
- **Pre-existing stale docs.** The reviewer noted `docs/AGENTS.md:662,724` and `docs/claude-integration-test.md:17` still describe the `claude-review` label trigger as working. Those statements were already inaccurate before this change, since the trigger never fired for PR labels. Left out of scope deliberately; worth a separate docs pass.

## Verification

```
python3 -c "yaml.safe_load(open('.github/workflows/claude-code-review.yml'))"
valid YAML; with-keys = ['anthropic_api_key', 'claude_args', 'trigger_phrase']; label_trigger present: False

PARALLEL_WORKERS=1 mise run test
99 runs, 456 assertions, 0 failures, 0 errors, 0 skips

mise exec -- git push   (pre-push hooks, no --no-verify)
12/12 green, including rails-tests, yaml-lint, verify_ci_ready, tailwind-build-check
```

Note: the repo's parallel test harness cannot start from a deep worktree path —
Rails opens a DRb Unix socket under `TMPDIR=$PWD/tmp` and macOS caps the path at
104 bytes. Run with `PARALLEL_WORKERS=1`. Environmental, unrelated to this change.
