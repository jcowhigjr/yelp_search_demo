# Antigravity & Gemini Project Guide for Yelp Search Demo

This file configures **Google Antigravity (AGY)** and all **Gemini models** (including Gemini 3.8 Flash, Gemini Pro, and future iterations) working in `yelp_search_demo`. It serves as the primary workspace rule for Antigravity conversations.

---

## 1. New Conversation Entrypoint & Confidence Check

Whenever a user starts a **"New conversation in project 'yelp_search_demo'"** or asks for an orientation, the agent MUST immediately ground itself in this repo's configuration and provide the user with confidence that best practices are active:

1. **Verify Toolchain**: Confirm commands are run via `mise exec --` or `mise run <task>`.
2. **Confirm Active Model & Reasoning Profile**:
   - For **Gemini 3.8 Flash**:
     - Default to **Medium reasoning effort** for routine tasks, script updates, single-component fixes, and standard reviews.
     - Recommend **High reasoning effort** for complex multi-file refactors, debugging async Hotwire/Cuprite race conditions, or full PR review-first loops.
3. **Safety & Hook Guardrails Active**:
   - Explicit file staging enforced (never `git add .`).
   - Automated git pre-commit/pre-push hooks enforced via `lefthook` (never `--no-verify`).
   - Empirically verify changes via tests before asserting completion.

---

## 2. New Model Arrival & Capability Refresher Protocol

When a new model generation arrives or when switched into a different Gemini model:

1. **Proactively Deliver the Capability Refresher**:
   - Summarize the model's key strengths (e.g. reasoning depth, Terminal-Bench 2.1 performance, multi-turn autonomy).
   - Recommend the optimal reasoning effort (`medium` vs `high`).
   - Highlight how to maximize the model's capabilities for this specific Rails 8 / Cuprite stack.
2. **Nudge Optimal Slash Commands**:
   - Recommend `/goal` for autonomous, multi-step debugging or long-running tasks.
   - Recommend `/grill-me` when aligning on ambiguous product/architecture decisions.
   - Recommend `/learn` when persisting local setup or debugging discoveries.

---

## 2b. Shared Skills

Skills in `.agents/skills/` are read directly by Antigravity and are shared with
every other harness in this repo (see `AGENTS.md` section 9). Keep them
harness-neutral: when a step needs a specific tool, add it to the skill's
"Tooling adapter" table rather than hardcoding Antigravity's API.

- `/groom-backlog` - TPM-style backlog refinement. Interviews the user issue by
  issue, plans delegation, and records decisions in `docs/ROADMAP.md`. It does
  **not** implement anything.
- `/model-refresher` - capability refresher when the active model changes.
- `/multi-model-review` - independent cross-model review of in-flight changes.

---

## 3. Core Repo Invariants & Rules

### A. Environment & Runtimes
* Treat `mise` as the top-level toolchain manager.
* Prefix all development commands: `mise exec -- <command>` (e.g. `mise exec -- bin/rails test`).
* Prefer named mise tasks:
  * `mise run test`: Run unit and integration tests.
  * `mise run test-system`: Run Cuprite headless browser system tests.
  * `mise run lint`: Run RuboCop linters.
  * `mise run brakeman`: Run Brakeman security scan.

### B. Critical Git Safety Rules
* **NEVER run `git add .` or `git add --all` or `git add -A`**.
* ALWAYS stage files explicitly: `git add <path/to/file>`.
* Before committing, verify staged files: `git diff --cached --name-only`.
* Target base branch `develop` requires linear history (no merge commits, no force-pushes without lease).
* Never bypass Git hooks with `--no-verify`.

### C. Frontend & Verification Standards
* **Stack**: Rails 8, Hotwire (Turbo + Stimulus via importmap), Propshaft, Tailwind CSS v4.
* **Tailwind CSS v4**: When modifying CSS/ERB templates, run `scripts/verify-tailwind-build.sh` to confirm utility compilation.
* **Cuprite System Tests**: Use headless Cuprite (`HEADLESS=true CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system`) to empirically verify UI/DOM interactions.
* **Visual Verification**: Use `mise exec -- bun run visual:verify --urls "<paths>"` (or `node scripts/visual-verification.js`) for deterministic UI screenshot comparison.

### D. PR & Review-First Loop
* On PR branches, unresolved review comments are blocking. Run `./scripts/review-loop.sh` before implementing other changes.

### E. Multi-Model Review & Escalation Hierarchy
When requesting an external review of changes:
1. **Warp Agent (Claude)**: Use interactive terminal prompt when cross-model planning review is desired (configured in `~/.warp/ai_preferences.yaml`).
2. **In-Situ Subagent Review**: Spawn an independent `research` subagent via `invoke_subagent` with an objective audit prompt to catch syntax, edge-case, and safety issues without leaving Antigravity.
3. **CLI Reviewers**: Use `agent codex review --uncommitted` (Codex) or `claude -p` (Claude). If token errors occur, run `claude auth login` in terminal for 2-step Chrome re-auth.
