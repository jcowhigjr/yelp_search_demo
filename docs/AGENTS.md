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
gh pr merge --auto --squash $PR_NUMBER
```

### Issue 3: Sequential Merging Causes Branch Behind State
**Issue**: After one Dependabot PR merges, remaining PRs become "behind" base branch.

**Root Cause**: Each merge changes the base branch, making other PRs outdated.

**Fix**: Use GitHub API to update branches programmatically:
```bash
# Update branch for a PR
# Note: Replace $GITHUB_REPOSITORY with actual owner/repo or use environment variable
gh api repos/$GITHUB_REPOSITORY/pulls/$PR_NUMBER/update-branch --method PUT

# Or close/reopen to trigger fresh CI
gh pr close $PR_NUMBER && gh pr reopen $PR_NUMBER
```

### Issue 4: Update Gemfile.next.lock Workflow Creates New Commits
**Issue**: When `Gemfile.next.lock` workflow creates commits, CI runs on old SHA.

**Root Cause**: The workflow creates a new commit after initial CI starts.

**Fix**: Ensure branch updates trigger new CI runs:
1. Use `update-branch` API after workflow completes
2. Or close/reopen PR to trigger fresh CI on latest commit

### Issue 5: Auto-Approval Race Condition with Gemfile.next.lock Updates ✅ RESOLVED
**Issue**: Dependabot PRs get auto-approved before `Gemfile.next.lock` updates complete, causing CI to never run on the final commit.

**Root Cause**: 
1. Dependabot creates PR → triggers `auto-approve.yml` + `main.yml` (CI)
2. `auto-approve.yml` immediately approves and enables auto-merge
3. `dependabot.next.yml` runs on push → updates Gemfile.next.lock → creates new commit
4. **New commit doesn't trigger fresh CI** because workflows were already running
5. Result: Auto-merge enabled but CI never ran on final commit

**Fix Applied (PR #[pending])**: Modified `auto-approve.yml` workflow to:
- **Wait for Gemfile.next.lock workflow**: Checks for running "Dependabot Update Gemfile.next.lock" workflow (5-minute timeout)
- **Sequential approval**: Only approves after Gemfile.next.lock workflow completes
- **Fresh CI trigger**: Updates PR branch after approval to ensure CI runs on final commit
- **Improved messaging**: Approval message indicates proper sequencing

**Validation**: 
- Pre-push hooks pass: 27 system tests, 59 Rails tests, all passing
- Zero breaking changes to existing workflows
- Backward compatible with branch protection rules

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
  # Note: Set GITHUB_REPOSITORY environment variable to owner/repo format
  gh api repos/$GITHUB_REPOSITORY/pulls/$pr/update-branch --method PUT
done
```

---

# AI Agent Hypothesis-Driven Development Methodology

## Problem: Race Conditions & Premature Conclusions

AI agents operating on remote systems (GitHub Actions, CI/CD, etc.) often fail by:
1. Checking results before processes complete
2. Not establishing measurable hypotheses
3. Missing feedback from automated reviewers
4. Declaring success without empirical validation

## The 6-Step Process

### Step 1: Record Timestamp & State Hypothesis

```
TIMESTAMP: [current time]
HYPOTHESIS: "When I [ACTION], I expect [MEASURABLE_OUTCOME] within [TIME_WINDOW]"
VALIDATION: [How will I know it worked?]
RISKS: [What could go wrong?]
```

### Step 2: Execute Action & Record Completion

### Step 3: Calculate & Wait Minimum Time

**Process Timing Windows:**
- Workflow trigger: 60-120s
- Workflow execution: 3-7 min  
- Automated review (Codex): 3-6 min
- PR merge (auto): 30-60s

### Step 4: Check Automated Feedback FIRST

```bash
# Wait 3+ minutes for automated reviewers
gh pr view <PR> --json comments,reviews
```

### Step 5: Check Results (After Min Wait)

### Step 6: Evaluate Hypothesis

```
HYPOTHESIS: [prediction]
RESULT: [actual outcome]
FEEDBACK: [all automated comments]
CONCLUSION: Correct/Incorrect/Inconclusive
```

## Key Rule

**Include automated reviewer feedback BEFORE evaluating hypothesis.**

Example: PR #911 Codex review caught that `env` variables were unset in `if` conditions, making the "fix" actually break the workflow.

---

# 🤖 Claude AI Code Review Integration

## Status: ✅ OPERATIONAL (Verified 2025-10-14)

Claude AI code review is fully integrated and manually verified working in GitHub Actions.

### 🎯 How to Use Claude Reviews

1. **Trigger a Review**: Comment `@claude` on any PR
2. **Wait 2-3 minutes**: Claude will analyze the code and respond
3. **Review Feedback**: Claude provides detailed, actionable recommendations

### ✅ Manual Verification Results (PR #920)

**Test Scenario**: Created deliberate test files with 10+ code quality issues including:
- Security vulnerabilities (command injection)
- Error handling gaps (nil checks, validation)
- Ruby anti-patterns (manual loops vs enumerables)
- Code quality issues (magic numbers, inefficient logic)

**Claude Performance**: 🏆 **EXCELLENT**
- ✅ Identified **ALL 10 planted issues** with specific examples
- ✅ Provided **actionable Ruby-specific recommendations**
- ✅ Categorized by severity (Critical/Error Handling/Code Quality)
- ✅ Included line-by-line code suggestions
- ✅ Analyzed both model and test files comprehensively

### 📋 What Claude Reviews Cover

#### 🔴 Critical Issues
- **Security vulnerabilities** (command injection, XSS, etc.)
- **Data validation gaps** that could cause runtime errors

#### 🟡 Error Handling & Robustness  
- **Missing nil/empty checks** in method parameters
- **Input validation** for user-facing methods
- **Exception handling** patterns

#### 🟢 Code Quality & Ruby Idioms
- **Non-idiomatic Ruby** patterns (manual loops vs enumerables)
- **Performance optimizations** (N+1 queries, inefficient algorithms)
- **Magic numbers** and hardcoded values
- **Method complexity** and single responsibility
- **Naming conventions** and readability

#### 📝 Test Coverage & Quality
- **Missing edge cases** in test coverage
- **Brittle testing** patterns (testing implementation vs behavior)
- **Test organization** and clarity

### 🔧 Technical Implementation

**Workflow File**: `.github/workflows/claude-code-review.yml`

**Triggers**:
- PR events: `opened`, `synchronize`, `reopened`  
- Comment events: `@claude` mentions
- Label events: `claude-review` label

**Authentication**: Uses both `ANTHROPIC_API_KEY` and GitHub OIDC tokens

**Permissions**: 
- `id-token: write` (for OIDC authentication)
- `contents: read` (to read PR files)
- `pull-requests: write` (to post review comments)

### 📊 Performance Metrics (Verified)

| Metric | Result |
|--------|--------|
| **Trigger Response Time** | ~12 seconds |
| **Analysis Completion** | 2-3 minutes |
| **Issue Detection Rate** | 100% (10/10 test issues found) |
| **False Positive Rate** | 0% (no incorrect recommendations) |
| **Recommendation Quality** | Excellent (actionable, specific) |

### 🚀 Integration Success Factors

1. **Issue #895 Resolution**: Fixed authentication issues through iterative debugging
2. **Workflow Event Triggers**: Corrected from `push` to `pull_request` events
3. **Environment Variable Scoping**: Fixed job-level vs step-level variable access
4. **GitHub Actions Permissions**: Added required `id-token: write` permission
5. **Manual Verification**: Comprehensive end-to-end testing with planted issues

### 🎯 Usage Recommendations

- **Use for complex PRs**: Particularly beneficial for large changes, new features
- **Security-focused reviews**: Excellent at catching injection vulnerabilities
- **Ruby optimization**: Strong at identifying non-idiomatic patterns
- **Pre-merge validation**: Good complement to automated testing and Codex reviews
- **Learning tool**: Great for junior developers to learn Ruby best practices

### 📚 Example Claude Review Output

```markdown
### 🔴 Critical Issues

#### 1. **Security Vulnerability - Command Injection** 
**Issue:** This method executes arbitrary system commands without validation
**Recommendation:** Remove entirely or use whitelist approach

### 🟡 Error Handling & Robustness

#### 2. **Missing Nil Check**
**Issue:** No validation that `@items` is not nil
**Recommendation:** Add `return 0 if @items.nil?` guard clause

### 🟢 Code Quality & Idioms  

#### 3. **Non-Idiomatic Ruby**
**Issue:** Manual accumulation instead of enumerable methods
**Recommendation:** Replace with `@items.sum { |item| item.fetch('price', 0) }`
```

### 🔄 Workflow Integration

Claude reviews integrate seamlessly with existing PR workflows:

1. **PR Creation** → Claude runs automatically (agent mode)
2. **Manual Trigger** → `@claude` comment for on-demand reviews  
3. **Review Response** → Detailed feedback posted as PR comment
4. **Iterative Process** → Request follow-up reviews after fixes

The Claude integration follows the same hypothesis-driven methodology as other automated tools - waiting for complete execution and including automated feedback in evaluation process.

## 🚀 Phase 1 Enhancement: GitHub Suggestion Comments

### New Feature: `@claude-suggest` Command

The enhanced Claude integration now supports **one-click code suggestions** through GitHub's native suggestion comment system.

#### How It Works

1. **Trigger**: Comment `@claude-suggest` on any PR
2. **Analysis**: Claude analyzes changed files and generates specific code improvements
3. **Suggestions**: Posted as GitHub suggestion comments on individual lines
4. **Apply**: Click "Apply suggestion" button to implement changes immediately

#### Suggestion Format

Claude generates suggestions in the proper GitHub format:

```markdown
**🤖 Claude Suggestion**

[Explanation of why this improves the code]

```suggestion
[actual code replacement]
```
```

#### Benefits Over Regular Comments

- **One-click application**: No copy/paste needed
- **Line-specific**: Suggestions appear exactly where needed
- **Version control**: Applied suggestions create proper commits
- **Batch application**: Apply multiple suggestions efficiently
- **Conflict prevention**: GitHub handles merge conflicts automatically

#### Usage Examples

**Security Fix Suggestion:**
```suggestion
return 0 if items.nil? || items.empty?
```

**Ruby Idiom Improvement:**
```suggestion
items.sum { |item| item.fetch('price', 0) }
```

**Performance Optimization:**
```suggestion
User.includes(:reviews).where(active: true)
```

#### Technical Implementation

- **Workflow**: `.github/workflows/claude-code-review-suggestions.yml`
- **Trigger**: `@claude-suggest` comments (separate from `@claude`)
- **Parser**: Python script handles suggestion formatting and GitHub API
- **Review API**: Uses GitHub's pull request review system for line comments

This enhancement maintains all existing Claude functionality while adding actionable, one-click code improvements.
