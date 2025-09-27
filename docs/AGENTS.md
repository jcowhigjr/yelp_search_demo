# Agents: No-Toil Dependabot Automation (One-Pass)

Use this quick checklist when eliminating manual Dependabot toil.

## TL;DR checklist
- Auto-approve + auto-merge (squash) all Dependabot PRs after checks pass
- Weekly, grouped Dependabot updates to reduce PR noise
- Scheduled refresher to comment `@dependabot recreate` on stale PRs and re-queue auto-merge
- Make `bin/setup` lefthook install resilient (fallback to `bundle exec`)
- Ensure `lefthook` is available in CI (`Gemfile` group :development, :ci)

## One-pass task spec (copy/paste into an issue/PR description)
- Repo: owner=jcowhigjr repo=yelp_search_demo
- Branch: chore/ci-dependabot-automation (or current feature branch)
- Do exactly the following in one PR:
  1) Update `.github/workflows/auto-approve.yml` to:
     - approve Dependabot PRs; enable `gh pr merge --auto --squash $PR_NUMBER`
     - condition `if: github.actor == 'dependabot[bot]'`
  2) Add `.github/dependabot.yml` with:
     - interval: weekly (Sunday, 07:00 PT)
     - groups: rubocop-suite, rails-ecosystem, dev-tools, test-stack, perf-and-runtime, patch-and-minor
  3) Add `.github/workflows/dependabot-refresh.yml` to:
     - detect stale Dependabot PRs (>=25 days or auto-rebase disabled notice)
     - comment `@dependabot recreate`
     - re-enable auto-merge (squash)
  4) Harden `bin/setup` for lefthook:
     - try `lefthook install`, fallback to `bundle exec lefthook install`, else skip
  5) Ensure `Gemfile` includes `lefthook` in `group :development, :ci`
  6) Commit, push, open PR to `develop`, enable auto-merge (squash)
  7) Verify: pre-push hooks pass; PR URL posted; auto-merge queued

## CLI snippets (manual fallback)
- List Dependabot PRs:
  - `gh pr list --author "dependabot[bot]" --json number --jq '.[].number'`
- Refresh and queue auto-merge for each `<num>`:
  - `gh pr comment <num> -b "@dependabot recreate"`
  - `gh pr merge --auto --squash <num>`

## Notes
- Requires: repo "Allow auto-merge" enabled; Actions `GITHUB_TOKEN` has PR write perms
- Branch protection: required checks must pass for auto-merge to execute
- Run this reminder anytime: `lefthook run workflow-status`

## ⚠️ CRITICAL: `@dependabot rebase` vs `@dependabot recreate`

**Problem**: When Dependabot PRs have been modified by automation (auto-approve workflows, manual edits), Dependabot refuses `@dependabot rebase` with:
```
"looks like this PR has been edited by someone other than Dependabot. That means Dependabot can't rebase it - sorry!
If you're happy for Dependabot to recreate it from scratch, overwriting any edits, you can request @dependabot recreate."
```

**Solution**: Always use `@dependabot recreate` instead of `@dependabot rebase` when PRs have been auto-approved or modified.

**Commands**:
- ❌ `@dependabot rebase` - Will fail if PR was modified
- ✅ `@dependabot recreate` - Always works, creates fresh PR from scratch

## CI Workflow Troubleshooting

### Issue 1: Workflow_run Trigger Blocking CI
**Issue**: Dependabot PRs showing 0 status checks, stuck as "blocked" despite auto-merge enabled.

**Root Cause**: `workflow_run` triggers can prevent CI from running on PR synchronize events.

**Fix**: Replace `workflow_run` with direct `pull_request` triggers:
```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
```

### Issue 2: Auto-Merge Disabled After Close/Reopen
**Issue**: When PRs are closed and reopened (to trigger CI), auto-merge gets disabled.

**Root Cause**: GitHub disables auto-merge when a PR is closed.

**Fix**: After reopening PRs, re-enable auto-merge:
```bash
gh pr merge --auto --squash <PR_NUMBER>
```

### Issue 3: Sequential Merging Causes Branch Behind State
**Issue**: After one Dependabot PR merges, remaining PRs become "behind" base branch.

**Root Cause**: Each merge changes the base branch, making other PRs outdated.

**Fix**: Use GitHub API to update branches programmatically:
```bash
# Update branch for a PR
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/update-branch --method PUT

# Or close/reopen to trigger fresh CI
gh pr close {PR_NUMBER} && gh pr reopen {PR_NUMBER}
```

### Issue 4: Update Gemfile.next.lock Workflow Creates New Commits
**Issue**: When `Gemfile.next.lock` workflow creates commits, CI runs on old SHA.

**Root Cause**: The workflow creates a new commit after initial CI starts.

**Fix**: Ensure branch updates trigger new CI runs:
1. Use `update-branch` API after workflow completes
2. Or close/reopen PR to trigger fresh CI on latest commit

### Complete Recovery Process for Stuck Dependabot PRs
```bash
# For each stuck Dependabot PR
for pr in $(gh pr list --author "dependabot[bot]" --json number --jq '.[].number'); do
  echo "Processing PR #$pr..."
  # Close and reopen to trigger CI
  gh pr close $pr && gh pr reopen $pr
  # Re-enable auto-merge
  gh pr merge --auto --squash $pr
done

# Wait for CI to complete, then update branches for sequential merging
for pr in $(gh pr list --author "dependabot[bot]" --json number --jq '.[].number'); do
  gh api repos/{owner}/{repo}/pulls/$pr/update-branch --method PUT
done
```
