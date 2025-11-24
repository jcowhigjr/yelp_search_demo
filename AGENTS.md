# AGENTS.md

This file defines **project-wide rules for all AI agents** working in this repository (Warp, Codex, Claude, Copilot-style tools, etc.).

For Warp-specific details, see `WARP.md`.
For deep policy and methodology, see `docs/AGENTS.md`.

---

## 1. Core runtime & workflow rules

- **Agents run routine commands autonomously**
  - For common operations (e.g., `git status`, `git add`, `git push`, `mise exec -- ./scripts/...`), agents SHOULD:
    - Run the commands themselves via available tools/CLI.
    - Avoid asking the user to type or copy/paste simple commands.
  - The only exceptions are actions that require:
    - Interactive secrets or credentials the agent cannot access, or
    - Explicit human sign-off for risky/destructive operations (e.g., deleting data).

- **Always sync first**
  - Before doing any work in this repo, run:
    - `./scripts/git-sync.sh`
  - Goal: ensure `develop` is up to date, old merged branches are cleaned up, and you are not working on stale code.

- **Use the mise toolchain**
  - Prefix all runtime commands with:
    - `mise exec -- <command>`
  - Prefer named mise tasks over raw commands when they exist, for example:
    - `mise run test` instead of manually invoking the full Rails test suite command
    - `mise run test-system` for system tests
    - `mise run brakeman` for security scans
  - Treat `WARP.md` and `mise.toml` as the source of truth for the authoritative list of mise tasks used by CI and hooks.

- **Never bypass hooks**
  - Do **not** use `--no-verify` with Git.
  - Respect lefthook workflows and scripts; they enforce tests, audits, and PR review loops.

- **Prefer lefthook workflows for Git operations**
  - Example: create a new feature branch using:
    - `lefthook run workflow-new-feature feature/<branch-name>`
  - Use descriptive branch names, typically prefixed with `feature/` (or `bugfix/` when appropriate), for example: `feature/agents-config-docs`.
  - Use helper scripts under `scripts/` (e.g., `sync-branch.sh`, `pr-lifecycle.sh`) instead of bespoke Git flows.

---

## 2. Review-first & delayed feedback behavior

When working on **any branch that has an open GitHub pull request**, agents MUST treat automated feedback (Codex, Claude, Copilot, human review) as the **highest priority** work.

### 2.1. GitHub MCP review loop (PR-focused)

When a PR exists for the current branch:

1. **Use the GitHub MCP server first** (when available):
   - Call `pull_request_read` with `method: "get_reviews"` to fetch the latest review states (APPROVED, CHANGES_REQUESTED, COMMENT).
   - Call `pull_request_read` with `method: "get_review_comments"` to fetch inline review comments with file path and line.
   - Detect **new** reviews/comments (not previously processed) and summarize them as top-priority tasks.
2. **Track what has been handled**
   - Keep track (in agent memory/state) of which review IDs and review comment IDs have already been addressed.
   - On each new invocation, surface only newly-arrived feedback and update the tracked state after planning fixes.

### 2.2. Repo-specific review loop (`jcowhigjr/yelp_search_demo`)

For this repository specifically:

- Run the review loop script before any other PR-branch work:

  ```bash
  ./scripts/review-loop.sh
  ```

- Treat unresolved review threads (Codex, Claude, Copilot, human) as blocking:
  - Read ALL review comments.
  - Propose and implement code changes to address each.
  - Commit and push (respecting hooks).
  - Resolve the review threads via the documented GraphQL / helper scripts.

This behavior matches the Phase 0 "review-first" protocol described in `WARP.md` and expanded in `docs/AGENTS.md`.

### 2.3. Example review-first loop iteration

A single iteration of the review-first loop should look like this:

1. **Check for feedback**
   - Use the GitHub MCP `pull_request_read` tool (`get_reviews` + `get_review_comments`) and `./scripts/review-loop.sh` to detect any new reviews or unresolved threads for the current PR.
2. **Plan fixes**
   - For each new comment, identify the file/line, restate the issue in your own words, and plan the minimal code/doc change needed.
3. **Implement + verify**
   - Make the changes, run relevant tests (and visual checks when needed), and ensure everything passes locally.
4. **Respond and re-check**
   - Push the changes, respond on the PR if appropriate, then re-run the review loop to confirm there is no remaining unresolved feedback before moving on.

---

## 3. Empirical verification & cross-model escalation

Agents MUST prefer **empirical verification** over reasoning alone.

- For code changes:
  - Run the appropriate Rails tests via `mise exec -- bin/rails test ...`.
  - Use system tests / headless verification (Cuprite, Puppeteer/Playwright MCP) for non-trivial UI changes.
- For tricky bugs or cross-layer issues:
  - Use the cross-model prompts provided by:
    - `scripts/generate-cross-model-prompt.sh`
    - `scripts/ai-css-review.sh`
  - Escalate to tools like `claude-cli` only **after** an empirical attempt has been made and captured.

See `docs/AGENTS.md` for the full hypothesis-driven development methodology (Issue #981) and the headless visual verification policy (Issue #982).

---

## 4. Tool-specific notes

### Warp (warp.dev)

- Warp agents should:
  - Treat this `AGENTS.md` as the cross-agent rules file.
  - Use `WARP.md` for Warp-specific runtime commands, git workflows, and PR completion protocols.
  - Consult `docs/AGENTS.md` when deeper policy or examples are needed.

### Codex / GitHub-based agents

- Codex and other tools that look for `AGENTS.md` at the repo root should:
  - Obey the review-first rules above.
  - Prefer GitHub MCP + `./scripts/review-loop.sh` for discovering delayed reviews on PRs.

### Claude / claude-cli

- Claude-specific configuration is in `CLAUDE.md`.
- For local workflows (e.g., `claude-cli`):
  - Use the prompts generated by `scripts/generate-cross-model-prompt.sh` and `scripts/ai-css-review.sh`.
  - Follow the empirical verification and escalation guidelines from `docs/AGENTS.md`.

---

## 5. Source-of-truth hierarchy

In case of conflict or ambiguity:

1. **Project rules:** This `AGENTS.md` file (cross-agent contract).
2. **Warp-specific details:** `WARP.md`.
3. **Deep policy & methodology:** `docs/AGENTS.md`.

Agents should resolve discrepancies by:
- Favoring more recent, explicit guidance.
- Avoiding changes that would violate the review-first protocol or empirical verification requirements.