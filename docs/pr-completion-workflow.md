# PR Completion Workflow

Comprehensive guide for AI agents to autonomously complete pull requests from code fix through merge.

## Overview

This workflow ensures agents can work on PRs without requiring repeated "continue" prompts by establishing clear phases, decision points, and autonomous behaviors.

**Goal**: Reduce user prompts from 4+ per PR to 0-1 for standard workflows.

## Phase 0: Review Loop (HIGHEST PRIORITY)

**Always start here when working on an existing PR.**

> **Reminder:** GitHub sets `mergeStateStatus=BLOCKED` whenever *any* review thread (human or automated) remains unresolved. Treat Codex (`@codex review` / `@codex address that feedback`) and Claude (`@claude`, `@claude-suggest`) comments exactly like human reviewers: fix, reply, resolve.

### Checklist

- [ ] Check for PR reviews using GitHub API/GraphQL
- [ ] If reviews exist:
  - [ ] Read ALL review comments (inline and general)
  - [ ] Address EACH comment in code
  - [ ] Commit changes with descriptive message
  - [ ] Push (triggers pre-push hooks automatically)
  - [ ] Reply to each comment documenting the fix
  - [ ] Resolve each thread via GitHub GraphQL API
  - [ ] GOTO Phase 0 (check for new reviews)
- [ ] If NO reviews exist, proceed to Phase 1

If GitHub still reports `mergeStateStatus=BLOCKED`, re-run `./scripts/review-loop.sh`—even automated reviewers show up as threads in that output.

### Commands

```bash
# Check for unresolved review threads
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 5) {
              nodes {
                body
                path
                line
              }
            }
          }
        }
      }
    }
  }
' -f owner=OWNER -f repo=REPO -F number=PR_NUMBER

# Resolve a thread after addressing feedback
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "THREAD_ID"}) {
      thread {
        id
        isResolved
      }
    }
  }
'
```

### Decision Logic

```
START: Working on PR
  ↓
  Check for review threads
  ↓
  ├─ Has unresolved threads?
  │  ├─ YES → Fix code → Push → Reply → Resolve → GOTO START
  │  └─ NO → Continue to Phase 1
  ↓
```

### Critical Rules

1. **Never skip review checks** - Always check first when working on a PR
2. **Fix immediately** - Don't wait for user to say "address feedback"
3. **Resolve explicitly** - Use GraphQL API, don't assume threads auto-resolve
4. **Loop automatically** - Keep checking until no reviews remain

## Phase 1: Code Changes

Once all reviews are addressed, ensure code quality.

### Checklist

- [ ] All review feedback addressed (from Phase 0)
- [ ] Run tests locally: `mise exec -- bin/rails test`
- [ ] Run system tests if affected: `mise run test-system`
- [ ] Verify linting passes: `mise exec -- bundle exec rubocop`
- [ ] Check for security issues: `mise run brakeman`
- [ ] Commit changes with clear message
- [ ] Push to remote (pre-push hooks will run automatically)

### Pre-Push Hook Validation

When you push, lefthook automatically runs:
- Branch sync checks
- Linters (Rubocop, ERBlint, Prettier)
- Full test suite (unit + system)
- Security audits (Brakeman, bundle audit)
- Importmap audit

**Key Insight**: If push succeeds, code quality is already validated locally.

## Phase 2: CI/CD Verification

Wait for remote CI to confirm in clean environment.

### Checklist

- [ ] Check CI status: `gh pr checks`
- [ ] If CI is running, wait: `sleep 30 && gh pr checks`
- [ ] If CI fails:
  - [ ] Reproduce failure locally
  - [ ] Fix the issue
  - [ ] Push fix (GOTO Phase 1)
- [ ] Verify all required checks pass

### Commands

```bash
# Check current CI status
gh pr checks

# Wait and re-check
sleep 30 && gh pr checks

# Get detailed failure logs
gh run view --log-failed
```

### Decision Logic

```
Check CI status
  ↓
  ├─ All passing → Continue to Phase 3
  ├─ Still running → Wait 30s → Re-check
  └─ Failed → Reproduce locally → Fix → Push → GOTO Phase 1
```

## Phase 3: Review Process (Post-CI)

Ensure all review requirements are met.

### Checklist

- [ ] Re-check for unresolved review threads (might have new ones)
- [ ] If threads exist, GOTO Phase 0
- [ ] Check for required approvals: `gh pr view --json reviewDecision`
- [ ] Handle approval blockers:
  - [ ] Self-approval blocked? (Cannot approve own PR)
  - [ ] Code owner approval required?
  - [ ] Check if admin override is appropriate

### Commands

```bash
# Check review decision
gh pr view --json reviewDecision,reviews

# Check merge requirements
gh pr view --json mergeable,mergeStateStatus

# Check for approval blockers
gh api repos/OWNER/REPO/branches/BRANCH/protection
```

### Decision Logic

```
Check approval requirements
  ↓
  ├─ Self-approval blocked & admin access → Consider admin merge
  ├─ Code owner required & you are owner → Cannot self-approve
  ├─ Needs external approval → Document status, request user help
  └─ Approved → Continue to Phase 4
```

## Phase 4: Merge Preparation

Verify branch is ready for merge.

### Checklist

- [ ] Verify branch is up-to-date: `git fetch origin && git log HEAD..origin/develop`
- [ ] If behind, sync: `./scripts/sync-branch.sh develop`
- [ ] Check for merge conflicts: `gh pr view --json mergeable`
- [ ] Verify mergeable status: `gh pr view --json mergeStateStatus`
- [ ] If blocked, identify and resolve blockers

### Commands

```bash
# Check if branch needs updating
git fetch origin develop
git log --oneline HEAD..origin/develop

# Sync if needed
./scripts/sync-branch.sh develop

# Check merge status
gh pr view --json mergeable,mergeStateStatus,statusCheckRollup
```

### Decision Logic

```
Check branch status
  ↓
  ├─ Behind develop → Sync → GOTO Phase 1 (tests may need re-run)
  ├─ Has conflicts → Resolve → Push → GOTO Phase 1
  └─ Clean & up-to-date → Continue to Phase 5
```

## Phase 5: Merge Execution

Complete the PR by merging.

### Checklist

- [ ] Verify all previous phases complete:
  - [ ] No unresolved review threads
  - [ ] CI passing
  - [ ] Approvals met (or admin override justified)
  - [ ] Branch up-to-date
  - [ ] No merge conflicts
- [ ] Choose merge strategy:
  - [ ] Enable auto-merge (if approvals pending)
  - [ ] Execute admin merge (if self-approval blocked and justified)
  - [ ] Document blockers (if external dependency)

### Commands

```bash
# Enable auto-merge (merges when approved)
gh pr merge --auto --squash

# Admin merge (bypasses approval requirement)
gh pr merge --admin --squash

# Check why merge is blocked
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        mergeable
        mergeStateStatus
        reviewDecision
      }
    }
  }
' -f owner=OWNER -f repo=REPO -F number=PR_NUMBER
```

### Decision Logic

```
Attempt merge
  ↓
  ├─ Success → PR merged! ✅
  ├─ Blocked by pending approval → Enable auto-merge
  ├─ Blocked by self-approval → Use admin merge if justified
  ├─ Blocked by unresolved threads → GOTO Phase 0
  ├─ Blocked by failing CI → GOTO Phase 2
  └─ Unknown blocker → Document and request user help
```

### When to Use Admin Merge

Use admin override when:
- ✅ You are the PR author and code owner
- ✅ All CI checks pass
- ✅ All review threads resolved
- ✅ No external approvers available
- ✅ Changes are uncontroversial (doc updates, fixes, features as planned)

Do NOT use admin override when:
- ❌ CI is failing
- ❌ Review threads are unresolved
- ❌ Changes are controversial or experimental
- ❌ External stakeholder approval is genuinely needed

## Complete Workflow Diagram

```
┌─────────────────────────────────────────────┐
│ START: Working on PR                        │
└───────────────┬─────────────────────────────┘
                ↓
┌─────────────────────────────────────────────┐
│ PHASE 0: Check for Reviews                  │
│ - Query GitHub GraphQL for review threads   │
│ - If threads exist → Fix → Push → Resolve   │
│ - Loop until no threads remain              │
└───────────────┬─────────────────────────────┘
                ↓
┌─────────────────────────────────────────────┐
│ PHASE 1: Code Quality                       │
│ - Run tests locally                         │
│ - Commit and push (pre-push hooks validate) │
└───────────────┬─────────────────────────────┘
                ↓
┌─────────────────────────────────────────────┐
│ PHASE 2: CI/CD                              │
│ - Wait for remote CI                        │
│ - If fails → Reproduce → Fix → Back to P1   │
└───────────────┬─────────────────────────────┘
                ↓
┌─────────────────────────────────────────────┐
│ PHASE 3: Review Process                     │
│ - Re-check for new review threads           │
│ - Check approval requirements               │
│ - Handle blockers (admin override if valid) │
└───────────────┬─────────────────────────────┘
                ↓
┌─────────────────────────────────────────────┐
│ PHASE 4: Merge Prep                         │
│ - Sync with base branch                     │
│ - Resolve conflicts if any                  │
│ - Verify mergeable status                   │
└───────────────┬─────────────────────────────┘
                ↓
┌─────────────────────────────────────────────┐
│ PHASE 5: Merge                              │
│ - Enable auto-merge OR                      │
│ - Execute admin merge OR                    │
│ - Document blockers                         │
└───────────────┬─────────────────────────────┘
                ↓
           ✅ PR MERGED
```

## Escalation Criteria

Stop and ask user when:

1. **Controversial changes needed** - Review comment suggests architectural change
2. **External dependencies** - Waiting for external approver who is unavailable
3. **Security concerns** - Brakeman or audit failures that need discussion
4. **Test failures** - Cannot reproduce or fix test failures after multiple attempts
5. **Merge conflicts** - Complex conflicts requiring design decisions

## Success Metrics

Track these to measure workflow effectiveness:

- **Continue prompts per PR** - Target: 0-1 (from baseline of 4+)
- **Review loop autonomy** - % of review comments addressed without user prompt
- **Thread resolution rate** - % of addressed comments marked resolved automatically
- **Time to merge** - Full cycle from feedback received to PR merged
- **Autonomous completion rate** - % of PRs merged without user intervention

## Related Documentation

- [Review-First Autopilot Loop](./review-first-autopilot.md) - Detailed review handling
- [Git Workflow](./git-workflow.md) - Branch management and protection rules
- [PR Workflow](./pr-workflow.md) - PR lifecycle and automation scripts
- [WARP.md](../WARP.md) - Main agent instructions
