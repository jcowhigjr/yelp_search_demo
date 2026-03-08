# Autonomous Design Loop

This document defines the standing "design teammate" loop for small, autonomous UI iterations in this repository.

## Purpose

- Keep design work moving in small, reviewable PRs.
- Ground every iteration in the current repo rules, live production UI, latest preview deploy, and Figma references.
- Leave functional, architectural, and cross-surface product decisions for a human decision point.

## Required Inputs At The Start Of Every Iteration

Review these sources before making any design changes:

- `AGENTS.md`
- `docs/AGENTS.md`
- `WARP.md`
- `docs/website-design-improvement/README.md`
- `docs/website-design-improvement/agents-playbook.md`
- `docs/website-design-improvement/implementation-plan.md`

Reference surfaces:

- Production baseline: `https://dorkbob.herokuapp.com/`
- Latest PR preview deploy for the active branch
- Figma Make file: `cBXTTlkhEgX7f3IiPMst1d`
- Figma site: `https://thin-stick-32280158.figma.site/`

## Guardrails

Autonomous implementation is allowed only when all of the following are true:

- The work is limited to a single surface or tightly related surface.
- The change stays in views, CSS, and tests.
- No controller, model, database, or production configuration changes are required.
- No new feature semantics are introduced.
- No unresolved product decision exists.
- The work is not a cross-surface redesign.

If any guardrail fails, stop and produce a planning artifact instead of implementation.

## Iteration Workflow

1. Sync the repo and confirm the branch state.
2. Review the current agent instructions and relevant design docs.
3. Inspect open UI/design issues and the standing retrospective thread `#1228`.
4. Compare the targeted surface across production, the latest preview deploy, and Figma when relevant.
5. Select the highest-value small iteration.
6. Reuse an existing GitHub issue if one fits; otherwise create one with explicit acceptance criteria before coding.
7. Add a short rationale comment to `#1228` describing why this iteration was chosen.
8. Implement only the bounded view/CSS/test change.
9. Run the relevant Rails tests and visual verification.
10. Verify the preview deploy after it rebuilds.
11. Open or update the PR with baseline URL, preview URL, and screenshot-backed findings.
12. Follow the review-first loop until the PR is merged.
13. After merge, add a short retrospective comment to `#1228`.

## Definition Of Done

An iteration is done only when:

- The preview is measurably better than production on the targeted surface.
- Visual verification has been run against production and the preview deploy.
- The issue, PR, and retrospective trail are updated.
- The local repository is back on a clean `develop`.

## Current Working Set

- Standing retrospective / project-brain thread: `#1228`
- First next iteration issue: `#1737`

## Manual Trigger

Use this exact prompt to start the next autonomous pass:

`Run the next design iteration.`

## Planning-Only Trigger

Use this prompt when the next step should stop before code changes:

`Plan the next design iteration only; do not implement.`
