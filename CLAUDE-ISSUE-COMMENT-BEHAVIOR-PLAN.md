## Summary

`@claude` comments on plain GitHub **issues** currently trigger the `Claude Code Review` workflow but the job is skipped by the `if:` condition, because the workflow is only designed to operate on pull requests. This issue tracks clarifying and (optionally) extending the Claude workflows so that:

- It’s clear which contexts are supported (PRs only vs PRs + issues).
- We avoid confusing "workflow triggered but skipped" behavior when commenting `@claude` on issues.
- We can optionally introduce a lightweight "issue text review" mode in the future if desired.

---

## Current State

Claude-related files in this repo:

1. **Workflows**
   - `.github/workflows/claude-code-review.yml`
     - Triggers on:
       - `pull_request` events: `opened`, `synchronize`, `reopened`.
       - `issue_comment` events: `created`.
     - Job `claude-review` is gated by:
       ```yaml
       if: |
         github.actor != 'dependabot[bot]' && (
           github.event_name == 'pull_request' ||
           (github.event_name == 'issue_comment' &&
            github.event.issue.pull_request &&
            contains(github.event.comment.body, '@claude'))
         )
       ```
     - Effect:
       - `@claude` on a **PR** (or its issue thread) works as expected.
       - `@claude` on a **plain Issue** (no `issue.pull_request`) triggers the workflow but the job evaluates `if:` to false and is shown as **skipped**.
   - `.github/workflows/claude-code-review-suggestions.yml`
     - Triggers on:
       - `workflow_dispatch` with `pr_number` input, or
       - `issue_comment` `created` events containing `@claude-suggest` on a PR issue.
     - Strictly PR-focused: assumes a PR number and uses `gh pr diff`, `gh api ...pulls/$PR_NUMBER/...`, etc.

2. **Scripts & docs** (all appear still relevant/used as helpers)
   - `scripts/claude-setup-validation.sh`
     - Validates that Claude integration is wired up (mise, lefthook, GitHub CLI, workflow, secrets, repo config).
     - Its last "Next steps" hint (`mention @claude in any issue or PR`) is slightly misleading given the PR-only logic above.
   - `scripts/generate-cross-model-prompt.sh`
     - Generates a cross-model (Claude/Codex/etc.) escalation prompt for arbitrary diffs.
   - `scripts/ai-css-review.sh`
     - Generates a focused CSS/ERB diff prompt for Claude or other agents.
   - `docs/AGENTS.md`
     - Describes how and when to use Claude reviews, `@claude`, and `@claude-suggest`.

Nothing appears obviously redundant: workflows cover PR reviews and suggestion comments; scripts support validation and prompt generation; docs explain usage.

The main confusion is about **issue comments**: the workflows are written as **PR-only**, but some text (e.g., in `claude-setup-validation.sh`) suggests `@claude` is valid on issues as well.

---

## Problem

- When I comment `@claude ...` on a **plain issue** (e.g., planning issue), GitHub shows the workflow "eyes" icon, but the job is marked **skipped** because:
  - `github.event.issue.pull_request` is falsy for non-PR issues.
  - The `if:` condition therefore evaluates to false.
- This is surprising UX: it looks like Claude is wired to review issues, but nothing actually happens.
- It’s not obvious from the current docs which contexts are officially supported (PR-only vs PR+issues).

---

## Desired Behavior

Near term:

1. **Make supported contexts explicit**
   - If the workflows are intentionally PR-only, make that clear in:
     - `docs/AGENTS.md` (Claude section)
     - `scripts/claude-setup-validation.sh` ("Next steps" hints)
   - Avoid promising that `@claude` will work "on any issue" if it’s only supported on PRs.

Optional medium term:

2. **(Optional) Add a simple issue-text review mode**
   - Define a separate, low-risk path that:
     - Triggers on `issue_comment` with `@claude` when **no** `issue.pull_request` is present.
     - Treats the **issue body + latest comment** as plain text to review (e.g., plans, RFCs), rather than PR diffs.
     - Posts Claude’s response back as an issue comment.
   - Keep this path strictly separate from the PR review flow to avoid mixing concerns.

---

## Proposed Changes

### 1. Clarify PR-only behavior in workflows and scripts

- Update `scripts/claude-setup-validation.sh`:
  - Change the "Next steps" section from:
    - `2. Or mention @claude in any issue or PR`
  - To something like:
    - `2. Mention @claude on a pull request (or its discussion thread) to trigger a review`
  - Optionally, add a note that `@claude` on plain issues is **not** currently wired to run reviews.

- In `docs/AGENTS.md` (Claude integration section):
  - Add one or two bullets explicitly stating:
    - `@claude` and `@claude-suggest` are **PR-focused**.
    - They will not process plain GitHub Issues unless/until an "issue review" path is implemented.

### 2. (Optional) Add an "Issue Text Review" workflow later

If/when we decide we want `@claude` to work on plain issues, introduce a new workflow, e.g. `.github/workflows/claude-issue-review.yml`, that:

- Triggers on `issue_comment` events where:
  - `!github.event.issue.pull_request`, and
  - `contains(github.event.comment.body, '@claude')` (or a different trigger phrase, like `@claude-issue`).
- Extracts issue context:
  - Issue title
  - Issue body
  - Latest comment (or last N comments)
- Sends that text to Claude with a prompt tailored to "plan/RFC/requirements" review.
- Posts Claude’s feedback back as an issue comment.

This can be designed so it **does not conflict** with the existing PR review workflow.

---

## Acceptance Criteria

- [ ] `scripts/claude-setup-validation.sh` accurately describes that `@claude` is currently PR-only (or PR + PR-issue-thread), not plain Issues.
- [ ] `docs/AGENTS.md` clearly documents where `@claude` and `@claude-suggest` are supported.
- [ ] There is an explicit decision recorded in the docs/issue about whether to:
  - Keep Claude reviews PR-only, or
  - Add a future "issue text review" workflow.
- [ ] (Optional) If an issue-text workflow is implemented later, it lives in its own workflow file and does not interfere with the existing PR review flows.