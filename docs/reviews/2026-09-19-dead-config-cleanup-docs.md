# Review record - docs: remove dead docs and fix broken command/feature references

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-19 |
| Commit(s) reviewed | `7e963af` |
| Reviewer | `claude/sonnet-5` |
| Invocation | `claude -p "<fresh-context, falsification-required review>" --output-format json --allowedTools "Read,Glob,Grep,Bash(git diff:*),Bash(git log:*),Bash(git show:*),Bash(git grep:*),Bash(git status:*),Bash(mise:*),Bash(lefthook:*),Bash(ls:*)"` |
| Requested by | jcowhigjr, via a Claude Code session auditing docs/rules/CI for low-value content |
| Authored the change? | no |
| Fresh context? | yes |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo |

**Process note, disclosed rather than omitted:** partway through this review, the
author ran `git checkout`/`rebase` in the same worktree the reviewer was reading
from, moving `HEAD` out from under it. The reviewer noticed, said so
unprompted, and re-verified every remaining claim against the explicit SHA
`1748d94` rather than trusting `HEAD`. The findings below held up under that
re-check, but the collision was the author's process error - reviews should run
against a pinned ref or a separate checkout, not a worktree the author is
actively mutating. Not repeated for the sibling review.

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | low | The commit message claimed the dead `@claude-suggest` feature was "fixed in every file that mentioned it," naming three docs. `app/services/demo_service.rb:1` also mentions it and was untouched by this commit - the claim of exhaustiveness was false as literally stated. Mitigating: that file is fully deleted (comment included) in the sibling PR `chore/remove-conflict-debris`, so the mention is handled, just not by this commit. | fixed: commit message reworded to say "every doc," name the file explicitly, and state it is deleted outright in the sibling PR rather than implying this commit missed it. |

## Disproved

| Candidate | Why it does not hold |
|-----------|----------------------|
| "`lefthook run workflow-status`/`workflow-new-feature` do exist." | Ran both directly: `Error: hook workflow-status doesn't exist in the config` / same for `workflow-new-feature`, matching the commit message verbatim. |
| "`lefthook.yml` defines custom command groups beyond `pre-commit`/`pre-push`." | `grep -nE '^[a-zA-Z_-]+:' lefthook.yml` returns exactly those two. |
| "`@claude-suggest` / `claude-code-review-suggestions.yml` were never actually removed, or weren't removed in #1827." | `git log --diff-filter=D -- '.github/workflows/claude-code-review-suggestions.yml'` shows exactly `25dcab1 "Remove dead Claude review workflows (#1827)"`. |
| "The six deleted docs had incoming references somewhere in the tree." | `git grep` at `HEAD~1` for each basename returned zero hits, all six. |
| "`claude-agent-integration.md`'s referenced workflow/mise tasks actually exist." | `.github/workflows/claude.yml` does not exist; none of the six named `mise run claude-*`/`agent-status` tasks appear in `mise.toml`. |
| "The WARP.md conflict resolution dropped content that differed between branches." | All three conflict sections in the pre-fix `WARP.md` were byte-identical text; collapsing them lost nothing. |
| "Kept files (`docs/review-first-autopilot.md`, `agent.prompt.yml`, `.githooks/workflow-new-feature`, `workflow-new-feature.sh`) contradict the 'command doesn't exist' claim." | They reference a standalone script or a lefthook-generated shim that itself calls the broken `lefthook run workflow-new-feature` - not a working counter-example, and none were among the files this commit claimed to fix. |
| "The new, more specific PR-trigger description in CLAUDE.md overstates actual behavior." | Matches `claude-code-review.yml`'s actual `on:` block and pre-existing, untouched text in `docs/AGENTS.md` describing the same body/title gating. |

## Not reviewed

- **`chore/remove-conflict-debris` was reviewed separately.** Its record notes the reverse coupling: this PR's `WARP.md` fix is what makes that PR's "conflict markers: none remain" claim true tree-wide. Neither PR alone is the complete picture; both together are.
- **No runtime/CI execution was checked** beyond direct command reproduction (`lefthook run workflow-status`, etc.) - this is a docs-only change with no application code path to run.

## Verification

```
lefthook run workflow-status         -> Error: hook workflow-status doesn't exist in the config
lefthook run workflow-new-feature    -> Error: hook workflow-new-feature doesn't exist in the config
git log --diff-filter=D -- '.github/workflows/claude-code-review-suggestions.yml'
  -> 25dcab1 Remove dead Claude review workflows (#1827)
git grep <basename> at HEAD~1, for each of the 6 deleted docs -> zero hits, all six
```
