## Summary

We are seeing recurring cases where a PR branch is fully green (all required checks passing) but GitHub reports the branch as **out-of-date with the base branch** (`mergeStateStatus: BEHIND`) and/or `Update with rebase` fails, forcing manual branch update via merge commit or local sync scripts.

This issue documents examples and should drive a small improvement to our workflows and docs so agents handle this consistently.

---

## Examples

### Example 1: PR #1011 – Add AGENTS.md and align multi-agent config docs

- PR: https://github.com/jcowhigjr/yelp_search_demo/pull/1011
- Base: `develop`
- Head: `feature/website-design-theme-auth-ui`
- State:
  - All required checks (Rails CI, system tests, Claude workflows) are passing or intentionally skipped.
  - Review threads have been resolved (see `scripts/review-loop.sh` + `scripts/resolve-thread.sh` usage).
  - GitHub shows the warning: **"This branch is out-of-date with the base branch"** with an `Update branch` button in the UI.
  - `mergeStateStatus` via `gh pr view 1011 --json mergeStateStatus` is `"BEHIND"`.
  - The UI previously showed `Update with rebase` with the error: **"There was a problem generating the rebase commit."**
- Hypothesis:
  - `develop` advanced after this feature branch was created, and although we have kept tests green and addressed review threads, we still require an explicit branch update to satisfy branch protection (up-to-date base requirement).
  - The rebase failure suggests either a non-trivial conflict or GitHub’s rebase engine being unable to auto-resolve changes, even though a merge commit path or scripted `sync-branch` merge would succeed.

We should treat this as part of the normal PR lifecycle rather than a surprise, especially for agents.

---

## Additional observations from resolving PR #1011

- In this specific case, completing PR #1011 required:
  - Applying the Tailwind dark-mode fix, resolving all review threads, and keeping tests green.
  - Performing a merge from `develop` into the feature branch (via GitHub UI "Update branch" with a merge commit) to satisfy branch protection \(up-to-date base requirement\).
  - Enabling auto-merge (squash) on the PR so that once approvals were in place, the merge completed without further manual steps.
- Local sync via `./scripts/sync-branch.sh develop` reported the branch as up to date, but GitHub still considered the PR BEHIND, which suggests:
  - Our scripts align the local branch with `origin/develop`, but GitHub's `mergeStateStatus` can still require an explicit merge commit on the PR head in some edge cases.
  - For agents, it is safer to treat `mergeStateStatus: BEHIND` as authoritative and respond with a documented sync/merge path rather than relying solely on local git state.
- From an agent-behavior perspective, this reinforces a few goals:
  - Maximize local, scripted automation (e.g., `sync-branch.sh`, `review-loop.sh`, pre-push hooks) and minimize requests for the user to perform manual steps.
  - Prefer event- or state-driven behavior \(e.g., checking PR/CI state before acting\) to avoid race conditions like "tests green but BEHIND".
  - Use external reviews (Codex/Claude) where they add clear value, but avoid unnecessary remote prompts when local rules and scripts already encode the correct behavior.

---

## Proposed Next Steps

1. **Clarify expectations in docs/AGENTS.md and/or docs/pr-workflow.md**
   - Explicitly document that a PR can be fully green but still blocked with `mergeStateStatus: BEHIND` when `develop` has moved ahead.
   - Note that this is expected under our branch protection rules ("branch must be up to date before merging").

2. **Standardize how agents respond to BEHIND state**
   - When `mergeStateStatus: BEHIND` is detected (or the GitHub UI shows "This branch is out-of-date with the base branch"), agents should:
     - Prefer our existing sync helpers (e.g., `./scripts/sync-branch.sh develop` or equivalent) rather than clicking `Update branch` blindly.
     - Re-run tests (or rely on pre-push hooks) after the sync.
     - Re-run `./scripts/review-loop.sh` to ensure no new review threads are introduced.

3. **Investigate and document the `Update with rebase` failure mode**
   - Capture at least one concrete example (PR #1011) where `Update with rebase` fails but a merge commit or manual `sync-branch.sh` merge would succeed.
   - Decide whether we want agents to **always** use our scripted sync (`./scripts/sync-branch.sh develop`) instead of GitHub’s `Update with rebase`/`Update with merge` buttons.

4. **(Optional) Add CI or pre-merge guard around BEHIND state**
   - Consider a lightweight check script (or extend existing ones) that:
     - Uses GitHub API or `gh pr view` to detect `mergeStateStatus: BEHIND`.
     - Explicitly instructs agents to run the sync script before attempting to mark a PR as complete/merge-ready.

---

## Acceptance Criteria

- [ ] At least one doc (e.g., `docs/AGENTS.md` or `docs/pr-workflow.md`) clearly explains the BEHIND/"branch out-of-date" pattern and expected agent behavior.
- [ ] Our preferred method for updating a branch with the latest `develop` is documented (e.g., `./scripts/sync-branch.sh develop`).
- [ ] Agents understand that a PR can be green but still BEHIND, and they must resolve that before treating the PR as truly merge-ready.
- [ ] (Optional) Decision recorded on whether we should avoid GitHub UI `Update with rebase` in favor of scripted sync for reproducibility.
