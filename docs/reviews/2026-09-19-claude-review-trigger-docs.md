# Review record - docs: correct the Claude review trigger documentation

## Provenance

| Field | Value |
|-------|-------|
| Date (UTC) | 2026-09-19 |
| Commit(s) reviewed | `bc81530` (base) through the pre-review docs commit on `docs/claude-review-triggers` |
| Reviewer | `claude/opus-5` |
| Invocation | `claude -p "<fresh-context review: verify the NEW doc text against the workflow and action source; flag any new statement that is itself inaccurate>" --output-format json --allowedTools "Read,Glob,Grep,Bash(git diff:*),Bash(git log:*),Bash(git show:*),Bash(git status:*)"` |
| Requested by | jcowhigjr, via a Claude Code session |
| Authored the change? | no |
| Fresh context? | yes |
| Independent? | yes |
| Escalated to human? | no |
| Given | full repo |

The reviewer was asked specifically to flag statements the *fix* introduced that
are themselves wrong, on the grounds that a doc correction carrying a different
false claim is worse than the original error. It found two.

## Findings

| # | Severity | Finding | Disposition |
|---|----------|---------|-------------|
| 1 | medium | The new text claimed comment events are "the only trigger that actually starts a review". False. `checkContainsTrigger` has an `isPullRequestEvent` branch that matches `trigger_phrase` against the PR body **and title** with a word-boundary regex and returns `true`, producing a genuine review (`src/github/validation/trigger.ts:78-99`). The claim also contradicted the doc's own next bullet. A new inaccuracy introduced by the fix. | fixed in the commit carrying this record: the bullet now says PR events produce a real review when the body or title contains `@claude`, and cites `checkContainsTrigger`. |
| 2 | low | The new text said the action "needs its trigger phrase in the PR body", omitting the title. A reader could put `@claude` in the title, expect a no-op, and be surprised by a real review. | fixed: both locations now say "body **or title**". |
| 3 | low | "no-ops after ~10 seconds" presented a specific figure as established fact with nothing backing it in the workflow, the action source, or this repo. The only nearby number measures a different thing (time-to-first-response on a successful trigger). | fixed: reworded to describe the mechanism ("logs 'No trigger found, skipping remaining steps' and returns without failing") and attributes the number to what it is - observed skipped runs on this repo completing in 10-12s. |

## Disproved

| Candidate finding | Why it does not hold |
|-------------------|----------------------|
| "The label-trigger claim is wrong." | Verified against `trigger.ts` and `context.ts`: `isIssuesEvent` checks `context.eventName === "issues"`. A PR label change dispatches `pull_request`, never `issues`, regardless of subscribed types - and this workflow does not subscribe to `labeled` anyway. Claim holds. |
| "`trigger_phrase` is not `@claude`." | Matches `claude-code-review.yml` verbatim: `trigger_phrase: "@claude"`. The old docs' `@claude-review` was wrong. Claim holds. |
| "`contents: write` is wrong." | Matches the workflow's actual block (`contents: write  # Required for commits`). The old `contents: read` was stale. Claim holds. |
| "'A green check does not mean Claude reviewed the PR' overclaims." | Verified in `prepare.ts`: when `checkContainsTrigger` returns false for a `pull_request` event, the action logs "No trigger found, skipping remaining steps" and returns without `core.setFailed`, so the job reports success. Claim holds. |
| "The comment-event enumeration is wrong." | "a comment containing `@claude` on a PR, a PR review, or a PR review comment" correctly maps the three non-`pull_request` branches of the workflow's `if:` (`issue_comment`, `pull_request_review`, `pull_request_review_comment`), each against the right payload field (`comment.body` vs `review.body`). |
| "'in the PR body' is an outright falsehood rather than an omission." | It does not state the title is excluded; it just failed to mention it. Recorded as incompleteness (finding 2), not a false statement. |

## Not reviewed

- **The corrected text was not re-reviewed independently.** Findings 1-3 were fixed in response to this review and verified by the author against `trigger.ts` only. Given the first draft introduced a medium inaccuracy, a second pass is a reasonable ask before merge.
- **Runtime behaviour was not exercised.** No PR was opened with `@claude` in the title to confirm the title path fires in practice; the claim rests on reading `trigger.ts`.
- **Other documents were not audited** for the same stale claims beyond the two files changed here. A post-fix `grep` did catch a third `@claude-review` occurrence the reviewer did not flag (`docs/AGENTS.md:194`, a cross-reference line outside the diff it was given); that is fixed here, but the grep was the author's, not the review's.

## Verification

```
grep -rn "claude-review` label\|@claude-review\|contents: read" docs/ .github/
  (no remaining matches outside docs/reviews/ and the historical record)
```

Source checks behind each corrected claim:

```
src/github/validation/trigger.ts:38   isIssuesEvent(context) && eventAction === "labeled"   -> label path is issues-only
src/github/validation/trigger.ts:78-99 isPullRequestEvent -> matches PR body AND title       -> finding 1 and 2
.github/workflows/claude-code-review.yml  trigger_phrase: "@claude"; contents: write
```
