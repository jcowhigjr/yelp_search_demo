---
mode: agent
description: "Use Rails system tests (Cuprite) to SEE and verify code changes"
tools: ['codebase', 'search', 'todos', 'runCommands', 'runTasks', 'runTests']
---
You are requested to visually confirm behavior using Rails system tests (Cuprite).

You MUST:
- Prepare tests: `mise run test-prepare`
- Run all tests: `mise exec -- bin/rails test`
- Run system tests headless (Cuprite): `HEADLESS=true CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system`
- Capture before/after behavior. Prefer a focused temporary system test with `save_screenshot` or a failing assertion to record state; remove temp code after verification.
- Iterate: make a small change, re-run system tests, compare results.
- Align with hooks/CI (no --no-verify): `lefthook run pre-push`

You SHOULD:
- Reload dev processes as needed to apply changes (e.g., `mise exec -- bin/dev`).
- Keep diffs small and single-concern.

Notes:
- Cuprite captures screenshots on failure; you can add `save_screenshot` to force artifacts.
- Use repo doc commands exactly to match CI.

Acceptance Criteria
- `.github/prompts/rails-system-tests.prompt.md` exists and uses our documented commands.
- Running the documented commands locally verifies behavior before and after a change.
- `docs/pr-workflow.md` links to the prompt and explains usage.
- Pre-push hooks pass locally without `--no-verify`.
