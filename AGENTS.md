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

- **CRITICAL: Confirm Acceptance Criteria & Linked Issue Before Starting Work**
  - **Before any non-trivial changes**, agents MUST:
    1. **Confirm with user** that there are clear Acceptance Criteria (A/C)
    2. **Verify there is a linked GitHub issue** for the work
    3. **Have a clear plan** with each A/C mapped to implementation steps
    4. **Scope confirmation** - ensure the work is within bounds and not "out of scope"
    5. **Assess test coverage** - identify existing tests that may be affected and plan test updates
  - **Non-trivial changes include**:
    - Any work that requires a new Pull Request
    - New system or unit tests
    - Production environment changes
    - New features or systems (like FeatureFlags)
    - Database schema changes
    - Major refactoring
  - **Examples of trivial changes** (don't need A/G confirmation):
    - Simple bug fixes with clear reproduction steps
    - Documentation updates
    - Minor styling tweaks
    - Adding missing tests for existing code
  - **If no issue exists**: Create one first before starting implementation
  - **If A/C unclear**: Ask user to define them before proceeding

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

- **Terminal command safety & escaping**
  - **CRITICAL**: Be extremely careful with command line arguments to prevent terminal hangs
  - **Never embed complex multi-line content directly in terminal commands** - this causes buffer overruns and hangs
  - **For commands with complex arguments**: 
    - Use heredocs (`<<EOF`) or temporary files instead of inline content
    - Break complex commands into separate, simpler steps
    - Avoid deeply nested quotes or escape sequences
  - **Warning signs that indicate escaping issues**:
    - Commands with multiple levels of nested quotes
    - Very long single-line command arguments (>1000 characters)
    - Complex string interpolation with special characters
    - Multi-line content embedded in single command calls
  - **If a terminal command hangs**: Cancel immediately and simplify the approach using separate steps or temporary files.

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

## 3. Test coverage and non-brittle system tests

Agents MUST assess test coverage before making changes and maintain system tests in a non-brittle state.

- **Pre-change test assessment**
  - **Before implementing any change**, agents MUST:
    1. Identify existing unit tests that may be affected by the change
    2. Identify existing system tests that may be affected by the change
    3. Assess whether new tests are needed to cover the change
    4. Plan test updates alongside implementation changes

- **System test best practices**
  - **Test rendered behavior, not implementation details**:
    - Focus on what users see and interact with in the browser
    - Test DOM elements, user interactions, and accessibility
    - Avoid testing internal helper methods or implementation specifics
  - **Maintain separation of concerns**:
    - System tests should test full-stack behavior through the browser interface
    - Helper methods should be tested in dedicated unit tests (`test/helpers/`)
    - Do not include helper modules in system test classes
  - **Use robust selectors**:
    - Prefer semantic HTML elements and data attributes over CSS classes
    - Use `data-testid` attributes for elements that need specific targeting
    - Avoid brittle selectors that break with minor UI changes
  - **Test what's implemented, not what's planned**:
    - Write tests for current functionality, not future features
    - Use comments or skip tests for functionality not yet implemented
    - Update tests incrementally as features are added

- **Non-brittle test maintenance**
  - **Review test failures for brittleness**: When tests fail, assess if the failure reveals a real bug or test brittleness
  - **Prefer stable assertions**: Use assertions that test behavior rather than exact DOM structure
  - **Handle timing and async operations**: Use proper waiting strategies for dynamic content
  - **Mobile and responsive testing**: Ensure tests work across different viewport sizes
  - **Regular test maintenance**: Update tests when UI changes are intentional, not just to make tests pass

---

## 4. Empirical verification & cross-model escalation

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

## 5. Tool-specific notes

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

## 6. Source-of-truth hierarchy

In case of conflict or ambiguity:

1. **Project rules:** This `AGENTS.md` file (cross-agent contract).
2. **Warp-specific details:** `WARP.md`.
3. **Deep policy & methodology:** `docs/AGENTS.md`.

Agents should resolve discrepancies by:
- Favoring more recent, explicit guidance.
- Avoiding changes that would violate the review-first protocol or empirical verification requirements.