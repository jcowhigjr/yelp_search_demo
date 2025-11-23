## Summary

Align this repo with the emerging AGENTS.md standard so that **Warp**, **Codex**, **Claude/claude-cli**, and other agents all read a consistent set of project rules.

We already have:

- `WARP.md` at the repo root (Warp’s control file)
- `docs/AGENTS.md` with detailed agent policies (review-first workflow, empirical verification, Claude integration, etc.)

This issue proposes introducing a root `AGENTS.md` as the cross-agent “source of truth,” plus a small `CLAUDE.md`, while keeping Warp’s `WARP.md` in place and pointing to the same policies.

---

## Motivation

I primarily use:

- **Warp** (with WARP.md + docs/AGENTS.md)
- **Codex** and GitHub-based AI reviewers (Codex, Copilot, Claude on PRs)
- **claude-cli** for local planning and deep reviews

Different tools look in different places for project instructions:

- Warp prefers `WARP.md` (but is compatible with `agents.md` / `claude.md`).
- Codex and several other agents expect an `AGENTS.md` file at the **repo root**.
- Claude/claude-cli uses `CLAUDE.md` by default, with support for importing `AGENTS.md` via `@AGENTS.md` when configured.

Right now, the “real” rules live in `docs/AGENTS.md` and `WARP.md`. Adding a root `AGENTS.md` and `CLAUDE.md` will:

- Ensure **Codex and other AGENTS.md-aware tools pick up the same rules automatically**.
- Keep **Claude and claude-cli** in sync with those rules.
- Preserve **Warp’s** existing behavior via `WARP.md` with minimal changes.

---

## Goals

1. **Single source of truth**: Root `AGENTS.md` becomes the canonical cross-agent config file.
2. **Warp alignment**: `WARP.md` references `AGENTS.md` and `docs/AGENTS.md`, but still contains Warp-specific notes (e.g., `./scripts/git-sync.sh`, lefthook workflows, review-loop scripts).
3. **Claude alignment**: `CLAUDE.md` imports `AGENTS.md` and adds any Claude-specific notes (e.g., when/how to use claude-cli, escalation patterns).
4. **Review-first + delayed feedback behavior** is clearly encoded for all agents, including:
   - GitHub MCP `pull_request_read` (`get_reviews`, `get_review_comments`)
   - The `./scripts/review-loop.sh` behavior
   - Handling delayed Codex/Claude/human reviews on PRs (e.g., PR #1007 pattern).

---

## Proposed Changes

### 1. Add root `AGENTS.md`

Create a new `AGENTS.md` at the repo root that:

- Summarizes **core project rules** for all agents:
  - Always run `./scripts/git-sync.sh` before work.
  - Always use `mise exec --` for runtime commands.
  - Never bypass git hooks with `--no-verify`.
  - Review-first workflow:
    - Prefer GitHub MCP `pull_request_read` with `method: "get_reviews"` and `method: "get_review_comments"` to detect PR feedback.
    - For this repo (`jcowhigjr/yelp_search_demo`), also run `./scripts/review-loop.sh` before any PR-branch work.
  - Empirical verification requirements (tests + headless verification, etc.).
- Explicitly calls out **multi-agent usage**:
  - How Warp, Codex, Claude, and others should coordinate.
  - When to escalate to claude-cli for plan review or tricky bugs.
- Links to deeper docs:
  - `WARP.md`
  - `docs/AGENTS.md`
  - Any other relevant docs under `docs/`.

The root `AGENTS.md` should be concise but authoritative, with links into `docs/AGENTS.md` for full details instead of duplicating everything.

### 2. Update `WARP.md` to reference `AGENTS.md`

In `WARP.md` (root):

- Add a short “Multi-agent config” section near the top that says (roughly):

  - This repo uses `AGENTS.md` at the root as the cross-agent project configuration file.
  - Warp agents should treat `AGENTS.md` + `docs/AGENTS.md` as the primary policy source, and use `WARP.md` for Warp-specific guidance (e.g., `./scripts/git-sync.sh`, lefthook workflows, review-loop, etc.).

- Ensure `WARP.md` explicitly mentions:
  - The review-first behavior already encoded (Phase 0 review loop).
  - That agents should also follow the **GitHub MCP review-first loop** described in `AGENTS.md` and `docs/AGENTS.md` (including handling delayed reviews like in PR #1007).

### 3. Add root `CLAUDE.md`

Add a small `CLAUDE.md` at the repo root that:

- Imports/points to `AGENTS.md` so Claude reads the same rules, for example:

  ```markdown
  @AGENTS.md

  # Claude-specific notes

  - Use claude-cli for:
    - Plan review on non-trivial features/bugs.
    - Deep-dive analysis when empirical checks are failing or inconclusive.
  - Follow the escalation patterns in `docs/AGENTS.md` (Issue #981 and related sections).
  ```

- Optionally includes any **Claude-specific** instructions (e.g., preferred models, when to use `@claude` vs `@claude-suggest` in PRs).

### 4. Keep `docs/AGENTS.md` as the deep-dive policy document

No major structural change needed, but:

- Confirm that `docs/AGENTS.md`:
  - Documents the **GitHub MCP review-first loop** (using `pull_request_read` with `get_reviews` and `get_review_comments`).
  - Mentions the `./scripts/review-loop.sh` script as the repo-specific implementation for Codex/Claude/human review threads.
  - Explains how agents should handle **delayed PR reviews**:
    - Always check for new reviews/comments at the start of any PR-branch work.
    - Treat newly arrived feedback as top priority before new coding work.

Root `AGENTS.md` can then link to specific sections in `docs/AGENTS.md` for the full methodology.

---

## Implementation Plan

1. **Create root `AGENTS.md`**
   - Draft a concise cross-agent rules document.
   - Pull core policies from `WARP.md` and `docs/AGENTS.md` without duplicating everything.
   - Include explicit review-first/MCP behavior and links to the deeper docs.

2. **Update `WARP.md`**
   - Add a short multi-agent section referencing root `AGENTS.md`.
   - Clarify how Warp agents should consume `AGENTS.md` + `docs/AGENTS.md`.

3. **Create root `CLAUDE.md`**
   - Import `AGENTS.md` (e.g., `@AGENTS.md`) and add Claude-specific usage notes.
   - Make sure it’s compatible with claude-cli / Claude Code.

4. **Light verification**
   - Manually confirm:
     - Warp still reads `WARP.md` and can “see” `AGENTS.md` / `docs/AGENTS.md`.
     - Codex and any other AGENTS.md-aware tools can detect `AGENTS.md` in the repo root.
     - Claude/claude-cli picks up `CLAUDE.md` and, through it, `AGENTS.md`.

---

## Acceptance Criteria

- [ ] Root `AGENTS.md` exists and clearly describes cross-agent project rules, including review-first/MCP behavior and references to `docs/AGENTS.md`.
- [ ] `WARP.md` explicitly references `AGENTS.md` as the central project config for all agents and remains accurate for Warp-specific workflows.
- [ ] Root `CLAUDE.md` exists, imports `AGENTS.md`, and adds any necessary Claude-specific notes.
- [ ] `docs/AGENTS.md` remains the detailed policy doc, with the GitHub MCP review-first loop and delayed-review handling clearly documented.
- [ ] Codex, Claude, and Warp all read compatible instructions without conflicting guidance.
