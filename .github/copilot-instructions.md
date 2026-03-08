# GitHub Copilot Review Instructions

Review pull requests in this repository with these priorities:

1. Review-first protocol
   - On PR branches, unresolved review feedback is blocking.
   - Prefer comments that identify missing handling for review threads, unresolved feedback loops, or automation that skips existing PR feedback.
   - If a change touches PR automation, GitHub scripts, or review tooling, verify it still supports `./scripts/review-loop.sh` and the repo's review-first workflow.

2. CI and workflow reliability
   - Focus on changes under `.github/workflows/`, `scripts/`, `lefthook.yml`, `mise.toml`, and setup/bootstrap scripts.
   - Look for duplicate workflow triggers, recursive workflow prevention, missing permissions, broken `workflow_dispatch` paths, and branch/update flows that leave PRs without required checks.
   - Flag workflows that assume a normal single-worktree checkout when the repository may be used from git worktrees or detached HEAD states.

3. Empirical verification expectations
   - Prefer comments when code changes are not backed by the right verification for the touched surface.
   - Rails/backend changes should usually have relevant `mise exec -- bin/rails test ...` coverage.
   - Non-trivial UI changes should be backed by system tests or headless browser verification, not reasoning alone.
   - Be skeptical of PR text that claims tests passed if the changed files suggest additional verification is needed.

4. Rails and application correctness
   - Favor idiomatic Rails patterns, safe migrations, clear controller/service boundaries, and tests that cover behavior instead of implementation details.
   - Flag security regressions, especially auth, secrets handling, shell execution, and GitHub token usage in automation.
   - Pay attention to environment-sensitive code paths in CI and deploy scripts.

5. Scope discipline
   - Prefer comments on behavioral regressions, reliability risks, and missing tests over style-only suggestions.
   - If a concern is out of scope but important, suggest tracking it in a follow-up issue instead of blocking the PR on unrelated cleanup.

When leaving review feedback, prioritize:
- Bugs and regressions
- Workflow and automation failures
- Missing or weak verification
- Security and permission mistakes
- Only then minor maintainability suggestions
