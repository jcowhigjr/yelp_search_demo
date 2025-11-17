---
mode: agent
description: "Use headless browser tests (Puppeteer/Playwright) to empirically verify non-trivial visual changes"
tools: ['codebase', 'search', 'todos', 'runCommands', 'runTasks', 'runTests']
---
You are requested to empirically verify **non-trivial visual/UI changes** using a headless browser (Puppeteer/Playwright), not just memory or inference.

Scope
- This workflow is **dev-only** and lives entirely in prompts and scripts.
- It MUST NOT require changes to the Rails application itself.

You MUST:
- Treat any non-trivial visual/UI change (layout, CSS, DOM structure, or interactions) as **not verified** until headless browser tests have run.
- Prefer a headless browser runner over assumptions:
  - If a Puppeteer MCP tool is available, use it to run relevant headless tests and capture screenshots/diffs.
  - Otherwise, if Playwright is configured, run the configured Playwright test command for the project.
- Run a targeted or full headless test suite that covers the changed surface.
- Summarize results explicitly in your output:
  - On success: state that headless browser tests passed and no unexpected visual diffs were detected.
  - On failure: list failing specs and point to screenshot/diff artifacts if available.
- Never silently update screenshot baselines. If a baseline update is needed:
  - Explain **why** (e.g., intentional UI change vs. regression).
  - Ask the user to confirm before updating baselines.
- Clearly distinguish between:
  - "I believe this is fine" (no empirical check), and
  - "I have run headless browser tests and confirmed behavior" (empirical verification).

You SHOULD:
- Prefer targeted runs based on changed files/paths when the project conventions support it.
- Use the same commands/flags locally that CI uses for headless tests, when known.
- Capture before/after behavior when helpful, via screenshots or visual diffs.

If headless browser verification is unavailable or fails to run:
- Say explicitly that empirical headless verification could not be completed.
- Treat the visual change as **not empirically verified** unless/until the user accepts that limitation.

Acceptance Criteria
- `.github/prompts/headless-visual-verification.prompt.md` documents a reusable policy for headless visual verification.
- Agents working on non-trivial visual/UI changes can include this prompt to ensure Puppeteer/Playwright-based empirical checks are performed when available.
- No changes to Rails application code are required to use this workflow.
