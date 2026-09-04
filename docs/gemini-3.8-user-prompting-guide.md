# Gemini 3.8 Flash & Antigravity User Prompting Guide

This guide details best practices for prompting and collaborating with **Gemini 3.8 Flash** inside **Google Antigravity** within `yelp_search_demo`.

---

## 1. Core Shift: Outcome-Oriented Prompting

Previous generations often required prescriptive step-by-step instructions. **Gemini 3.8 Flash** is specifically tuned for deep pre-action reasoning and multi-turn autonomous tool loops (scoring 90.8% on Terminal-Bench 2.1).

### Instead of Micro-Managing:
> *"Open app/controllers/searches_controller.rb, find line 42, add a check for params[:query], then run bin/rails test test/controllers/searches_controller_test.rb"*

### Prompt with Outcomes & Guardrails:
> *"Ensure searches reject empty queries with a clear flash notice. Verify with both controller tests and a headless Cuprite system test. Follow our mise toolchain and explicit git staging rules."*

The model will autonomously plan the changes, locate files, apply targeted edits, run the tests, and iterate until the tests pass.

---

## 2. What to Do After a `/goal` Run

When a `/goal` execution completes:

1. **Review the Generated Artifacts**:
   - Inspect the `walkthrough.md` artifact to see what was modified, what was tested, and the verification output.
   - Check `implementation_plan.md` for architectural context.
2. **Review Working Tree Changes**:
   - Run `git status` or inspect the "Files Changed" tab in Antigravity.
   - Run `git diff` on modified files.
3. **Run Independent Sanity Verification (Optional)**:
   - `mise run test` or `mise run test-system` to confirm local test suite status.
4. **Explicit Staging & Commit**:
   - Follow repo rules: NEVER run `git add .` or `git add --all`.
   - Stage explicit files: `git add <file1> <file2>`
   - Verify staging: `git diff --cached --name-only`
   - Commit with a descriptive message following Conventional Commits (e.g. `feat: ...`, `fix: ...`, `chore: ...`).
5. **Session Retro / Handoff**:
   - If the task was long-running or encountered multiple hurdles, ask the agent or invoke `/learn` to record patterns that should be remembered for future sessions.

---

## 3. Reasoning Effort Settings Guide

In Antigravity's settings menu (or model selector), you can adjust reasoning effort:

| Setting | When to Use | Typical Prompt Style |
| :--- | :--- | :--- |
| **Medium** *(Default)* | Day-to-day coding, bug fixes, test additions, reviewing PRs, writing documentation. | Concise instructions, bug reproduction descriptions, single-feature requests. |
| **High** | Complex multi-file refactors, debugging async Hotwire/Stimulus race conditions, resolving merge conflicts, full `/goal` sweeps. | High-level problem statements, architectural constraints, acceptance criteria. |

---

## 4. High-Leverage Slash Commands in Antigravity

* **/goal**:
  - **Purpose**: Autonomous, long-running execution without stopping for micro-approvals until the goal is achieved.
  - **Best for**: "Fix all flaky tests in test/system/", "Implement Issue #123 from requirements to passing tests".
* **/grill-me**:
  - **Purpose**: Forces the agent to interview *you* about edge cases, UX preferences, and architectural tradeoffs before touching code.
  - **Best for**: Ambiguous new feature ideas or major schema changes.
* **/learn**:
  - **Purpose**: Persists a technique, debugging fix, or repo invariant into agent memory for all future conversations.
  - **Best for**: After solving tricky environment issues, Heroku configuration quirks, or Cuprite timing issues.
* **/browser**:
  - **Purpose**: Launches interactive browser testing or visual inspection.

---

## 5. Using Context (@ Mentions) Effectively

* `@file` or `@folder`: Pin relevant files directly (e.g. `@app/models/coffeeshop.rb`).
* `@git`: Point to active branch status or specific commit diffs.
* `@rule`: Force-load a specific guideline if you want to remind the agent of a focused standard.
