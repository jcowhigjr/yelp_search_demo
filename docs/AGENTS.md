# Agents: No-Toil Dependabot Automation (One-Pass)

## 🎯 Definition of Done - Complete PR Workflow

**IMPORTANT**: Every PR must follow this complete workflow to ensure quality and maintainability.

### Automated PR Completion Loop
When creating any PR, the workflow should:

1. **Request Copilot Review**
   ```bash
   gh pr comment <PR_NUMBER> -b "@copilot-reviewer review"
   ```

2. **Monitor Loop** (automated sleep/check pattern)
   - Wait for Copilot review to complete
   - Address all review comments programmatically or manually
   - Re-request review if changes were made
   - Monitor CI status until all checks pass
   - Confirm auto-merge is enabled (or merge manually if needed)

3. **Verify Merge**
   - Poll PR status until `state: merged`
   - Confirm merge commit exists in base branch

4. **Clean Local Environment**
   ```bash
   # After PR is merged
   git checkout develop
   git pull origin develop
   git branch -d <feature-branch>  # Delete local feature branch
   git remote prune origin         # Clean up remote tracking branches
   ```

### Definition of Done Checklist
- [ ] Copilot review requested and feedback addressed
- [ ] All CI checks passing (tests, linting, security)
- [ ] Review comments resolved and approved
- [ ] PR merged to base branch
- [ ] Local repository on develop branch
- [ ] Latest changes pulled from remote
- [ ] Feature branch deleted locally
- [ ] Ready for next feature (clean working tree)

### Automated Implementation Pattern
```bash
#!/bin/bash
# Complete PR workflow automation

PR_NUMBER=$1
MAX_WAIT=1800  # 30 minutes timeout
CHECK_INTERVAL=30  # Check every 30 seconds

# Step 1: Request Copilot review
gh pr comment $PR_NUMBER -b "@copilot-reviewer review"

# Step 2: Monitor loop
elapsed=0
while [ $elapsed -lt $MAX_WAIT ]; do
  # Check PR status
  pr_status=$(gh pr view $PR_NUMBER --json state,mergeable,reviews,statusCheckRollup -q '.state')
  
  if [ "$pr_status" = "MERGED" ]; then
    echo "✅ PR merged successfully"
    break
  fi
  
  # Check if intervention needed
  reviews=$(gh pr view $PR_NUMBER --json reviews -q '.reviews[] | select(.state == "CHANGES_REQUESTED")')
  if [ -n "$reviews" ]; then
    echo "⚠️ Changes requested - manual intervention needed"
    # Could trigger automated fixes here
  fi
  
  sleep $CHECK_INTERVAL
  elapsed=$((elapsed + CHECK_INTERVAL))
done

# Step 3: Post-merge cleanup
if [ "$pr_status" = "MERGED" ]; then
  current_branch=$(git branch --show-current)
  git checkout develop
  git pull origin develop
  git branch -d $current_branch 2>/dev/null || echo "Branch already deleted"
  git remote prune origin
  echo "🎉 Ready for next feature!"
fi
```

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
