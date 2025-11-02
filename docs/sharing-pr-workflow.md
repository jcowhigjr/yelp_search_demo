# Sharing the Autonomous PR Completion Workflow

Guide for replicating this project's autonomous PR completion workflow in other repositories.

## Overview

This setup enables AI agents to autonomously complete pull requests from code fix through merge without requiring repeated "continue" prompts. It reduced user prompts from 4+ per PR to 0-1 in this project.

## What This Workflow Provides

### Core Capabilities

1. **Review-First Loop** - Agents automatically check for, fix, and resolve review comments
2. **PR Completion Validation** - Scripts validate all merge requirements (CI, reviews, conflicts, approvals)
3. **Autonomous Execution** - Agents loop through phases until PR is merged
4. **Clear Documentation** - Comprehensive guides for both agents and humans

### Success Metrics

- **Reduce "continue" prompts**: From 4+ to 0-1 per PR
- **Review autonomy**: Agent fixes comments without user intervention
- **Thread resolution**: Agent explicitly resolves GitHub threads
- **Autonomous completion**: PRs merge without manual orchestration

## Prerequisites

Your project needs:

1. **GitHub repository** with branch protection enabled
2. **GitHub CLI (`gh`)** installed and authenticated
3. **`jq`** for JSON parsing
4. **Bash-compatible shell** (bash/zsh)
5. **CI/CD pipeline** (GitHub Actions or similar)
6. **Git workflow** with pull requests

## How Branch Syncing Works

**This solution keeps branches up-to-date through multiple mechanisms:**

### 1. **Agent-Level Syncing** (Local)
- Agents run `./scripts/git-sync.sh` at session start (per WARP.md instructions)
- Syncs local `develop` with `origin/develop`
- Cleans up merged branches automatically
- Ensures agents always work with fresh code

### 2. **Automatic Detection** (During PR Work)
- `pr-completion-check.sh` detects when PR branch is behind base branch
- Reports it as a blocker in Phase 4
- Suggests running `./scripts/sync-branch.sh [base-branch]`
- Agents should automatically sync when detected

### 3. **GitHub Actions Workflow** (Remote PR Updates) - Optional but Recommended
- You can add `.github/workflows/auto-update-prs.yml` to automatically update PR branches when base branch changes
- Uses GitHub's `update-branch` API endpoint
- Runs whenever base branch (e.g., `develop`) is pushed to
- Updates remote PR branches automatically without manual intervention
- **Source project has this:** Copy `.github/workflows/auto-update-prs.yml` from yelp_search_demo

### 4. **Automatic Branch Cleanup** (After PR Merge) - Recommended
- Add `.github/workflows/cleanup-merged-branches.yml` to automatically clean up merged branches
- Runs when PRs are merged into base branches (`develop`, `main`)
- **Requires GitHub setting:** Enable "Automatically delete head branches" in repository settings
- Local cleanup: `git-sync.sh` prunes deleted branches when agents run it at session start

**Result:** Branches stay current through agent actions, script detection, and optional automated workflows. Merged branches are automatically cleaned up.

**To enable auto-update and cleanup workflows:**
```bash
# Copy the workflow files
mkdir -p .github/workflows
cp /path/to/yelp_search_demo/.github/workflows/auto-update-prs.yml .github/workflows/
cp /path/to/yelp_search_demo/.github/workflows/cleanup-merged-branches.yml .github/workflows/

# Update base branch names in workflows if not 'develop':
# - auto-update-prs.yml line 6: Change 'develop' to your base branch
# - cleanup-merged-branches.yml lines 7-8: Update base branches list

# Enable GitHub auto-delete for merged branches:
# Settings → General → Pull Requests → Enable "Automatically delete head branches"
```

## Files to Copy

### 1. Core Documentation

**Source:** `docs/pr-completion-workflow.md`
- Complete 6-phase workflow (Phase 0-5)
- Decision trees for each phase
- Commands and examples
- Escalation criteria

**Customization needed:**
- Update base branch name (if not `develop`)
- Update CI check names (if not `test`)
- Adjust commands for your test framework

**Target:** `docs/pr-completion-workflow.md`

---

**Source:** `docs/review-first-autopilot.md`
- Detailed review loop protocol
- Step-by-step implementation guide
- Common pitfalls to avoid
- GraphQL API examples

**Customization needed:**
- Update repository examples with your repo name
- Adjust pre-push hook references (if different)

**Target:** `docs/review-first-autopilot.md`

### 2. Helper Scripts

**Source:** `scripts/git-sync.sh`
- Syncs local develop branch with origin
- Prunes merged branches
- Should be run at conversation start to keep local repo fresh

**Customization needed:**
- Change `develop` to your base branch name (line 28, 38)
- Adjust branch cleanup logic if needed

**Target:** `scripts/git-sync.sh`

```bash
chmod +x scripts/git-sync.sh
```

**Note:** This script is recommended for agents to run at the start of each session to ensure they're working with latest code.

---

**Source:** `scripts/sync-branch.sh`
- Syncs feature branch with base branch
- Detects if branch is behind and auto-merges
- Handles conflicts gracefully

**Customization needed:**
- Change default base branch from `main` to your base (line 217)

**Target:** `scripts/sync-branch.sh`

```bash
chmod +x scripts/sync-branch.sh
```

**Note:** This is called automatically when `pr-completion-check.sh` detects branch is behind.

---

**Source:** `scripts/review-loop.sh`
- Checks for unresolved review threads
- JSON and human-readable output
- Exit codes for automation

**Customization needed:**
- None (repository-agnostic)

**Target:** `scripts/review-loop.sh`

```bash
chmod +x scripts/review-loop.sh
```

---

**Source:** `scripts/pr-completion-check.sh`
- Validates all 5 phases for PR readiness
- Checks CI status, reviews, conflicts, approvals
- **Detects if branch is behind base branch** (Phase 4)
- Provides actionable next steps including sync command

**Customization needed:**
- Line 122-123: Change `develop` to your base branch name
- Line 252: Update sync command to match your base branch (will reference `sync-branch.sh`)
- CI check validation is automatic (uses `gh pr checks`), but verify it matches your workflow

**Target:** `scripts/pr-completion-check.sh`

```bash
chmod +x scripts/pr-completion-check.sh
```

**Note:** When this script detects branch is behind, it will suggest running `sync-branch.sh`. Agents should do this automatically.

### 3. Agent Instructions

**Source:** `WARP.md` (PR Completion Protocol section)
- Lines 27-93 contain the protocol
- Review-first loop instructions
- Quick reference for autonomous behavior

**Customization needed:**
- Update script paths if different
- Adjust merge strategy if you don't use squash

**Target:** Add to your project's `WARP.md`, `CLAUDE.md`, or similar agent instruction file

## Step-by-Step Setup

### Step 1: Create Directory Structure

```bash
cd /path/to/your/project

# Create directories if they don't exist
mkdir -p docs
mkdir -p scripts
```

### Step 2: Copy Documentation

```bash
# From yelp_search_demo to your project
cp /path/to/yelp_search_demo/docs/pr-completion-workflow.md docs/
cp /path/to/yelp_search_demo/docs/review-first-autopilot.md docs/
```

### Step 3: Copy Scripts

```bash
cp /path/to/yelp_search_demo/scripts/git-sync.sh scripts/
cp /path/to/yelp_search_demo/scripts/sync-branch.sh scripts/
cp /path/to/yelp_search_demo/scripts/review-loop.sh scripts/
cp /path/to/yelp_search_demo/scripts/pr-completion-check.sh scripts/

# Make executable
chmod +x scripts/*.sh
```

**Script roles:**
- `git-sync.sh`: Sync local develop with origin (run at session start)
- `sync-branch.sh`: Sync feature branch with base branch (called automatically when behind)
- `review-loop.sh`: Check for unresolved review threads
- `pr-completion-check.sh`: Validate PR completion status

### Step 4: Customize for Your Project

#### A. Update pr-completion-check.sh

Edit `scripts/pr-completion-check.sh`:

```bash
# Line 122-123: Change base branch (replace 'develop' with your base branch)
git fetch origin main --quiet 2>/dev/null || true  # If you use 'main' instead of 'develop'
BEHIND_COUNT=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")

# Line 252: Update sync command to match your base branch
echo "  • Sync branch: ./scripts/sync-branch.sh main"  # If you use 'main'
```

**Note**: CI checks are automatically detected via `gh pr checks`, so no manual configuration needed unless you use a non-GitHub CI system.

#### B. Update Documentation

Edit `docs/pr-completion-workflow.md`:

1. Replace `develop` with your base branch name throughout
2. Update test commands to match your framework:
   ```bash
   # Original (Rails):
   mise exec -- bin/rails test
   
   # Your framework might be:
   npm test                    # Node.js
   pytest                      # Python
   go test ./...               # Go
   cargo test                  # Rust
   ```

3. Update CI check references if needed

#### C. Update Agent Instructions

**For different agent types:**

**GitHub Copilot Chat / GitHub Actions:**
- Add instructions to `.github/copilot-instructions.md` or similar
- Or include in repository README.md
- Agents will read these when scanning the repo

**WARP (warp.dev):**
- Add to `WARP.md` in project root (WARP automatically reads this)
- Or add to Warp's persistent rules feature

**Cursor / Claude (via Cursor):**
- Add to `.cursorrules` file
- Or include in `CLAUDE.md` in project root
- Or add to `.claude/` directory if using Claude Desktop

Add the following to your project's agent instruction file:

```markdown
## 🤖 SESSION START PROTOCOL

**ALWAYS run this FIRST before starting any work:**
```bash
./scripts/git-sync.sh
```

This ensures:
- Your local develop branch is synced with GitHub
- Old merged branches are cleaned up
- You're working with the latest code
- No conflicts from stale local state

## 🔄 PR COMPLETION PROTOCOL

**When working on an existing PR, ALWAYS follow this autonomous completion loop:**

### Phase 0: Review-First Loop (HIGHEST PRIORITY)

**Check for reviews BEFORE any other action:**
```bash
./scripts/review-loop.sh
```

If unresolved reviews exist:
1. Read ALL review comments
2. Fix each issue in code
3. Commit and push (pre-push hooks validate automatically)
4. Reply to each comment documenting the fix
5. Resolve each thread via GitHub GraphQL API:
   ```bash
   gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { id isResolved } } }'
   ```
6. **LOOP BACK** - Check for reviews again (Step 1)

**Critical**: Never wait for user to say "address feedback" - fix immediately and autonomously.

### Complete PR Workflow

Once all reviews are addressed:

```bash
# Check overall PR completion status
./scripts/pr-completion-check.sh
```

This validates:
- ✅ Phase 0: All review threads resolved
- ✅ Phase 1-2: CI checks passing
- ✅ Phase 3: Approval requirements met
- ✅ Phase 4: Branch up-to-date, no conflicts
- ✅ Phase 5: Ready to merge

**If branch is behind base:** The script will detect and suggest syncing. Agents should automatically sync:
```bash
./scripts/sync-branch.sh develop  # or your base branch name
```

This will:
1. Fetch latest from origin
2. Auto-merge base branch into feature branch
3. Push updates
4. Handle conflicts if any

### Merge Execution

When all phases complete:

```bash
# If approvals are pending (will merge when approved)
gh pr merge --auto --squash

# If self-approval blocked and changes are uncontroversial
gh pr merge --admin --squash
```

### Key Principles

1. **Review-first always** - Check for reviews before any other PR action
2. **Fix immediately** - Don't wait for prompts; address feedback autonomously
3. **Resolve explicitly** - Use GraphQL API to mark threads resolved
4. **Loop automatically** - Keep checking until no reviews remain
5. **Sync when behind** - If `pr-completion-check.sh` reports branch is behind, automatically run `./scripts/sync-branch.sh [base-branch]`
6. **Push immediately** - Pre-push hooks validate; don't wait for remote CI
7. **Complete to merge** - Goal is merged PR, not just "ready for review"

### Documentation

- **Full workflow**: [docs/pr-completion-workflow.md](./docs/pr-completion-workflow.md)
- **Review loop details**: [docs/review-first-autopilot.md](./docs/review-first-autopilot.md)
- **Helper scripts**: `./scripts/review-loop.sh`, `./scripts/pr-completion-check.sh`
```

### Step 5: Configure Branch Protection

Ensure your GitHub repository has these branch protection rules enabled for your base branch:

**Quick Link Format:**
```
https://github.com/[owner]/[repo]/settings/branches
```

**Steps:**
1. Go to: Settings → Branches → Branch protection rules → Edit [your-base-branch]
2. Enable these required settings:
   - ✓ Require a pull request before merging
   - ✓ Require conversation resolution before merging
   - ✓ Require status checks to pass before merging
     - Add your CI check name(s) (e.g., "test", "CI", "build", "lint")
   - ✓ Require branches to be up to date before merging

**Optional but recommended:**
- ✓ Require review from Code Owners (if you have CODEOWNERS file)
- ✓ Require signed commits
- ✓ Require linear history
- ⚠️ **Note**: If you want agents to use `--admin` merge, ensure "Do not allow bypassing" is **disabled** for admin accounts

### Step 6: Verify the Setup

**Run these verification commands before using in production:**

```bash
# 1. Verify scripts are executable and work
./scripts/review-loop.sh --json 2>&1 || echo "Expected: 'Not on a branch with an open PR' or JSON output"
./scripts/pr-completion-check.sh --json 2>&1 || echo "Expected: 'Not on a branch with an open PR' or JSON output"

# 2. Verify gh CLI authentication
gh auth status
gh pr view 2>&1 || echo "Expected: Error if not on PR branch, or PR details if on PR branch"

# 3. Verify jq is installed
jq --version

# 4. Create a test PR and verify workflow
git checkout -b test/pr-workflow-setup
echo "# Test PR Workflow" >> TEST.md
git add TEST.md
git commit -m "Test: PR workflow setup"
git push -u origin test/pr-workflow-setup
gh pr create --title "Test: PR Workflow Setup" --body "Testing autonomous PR completion workflow"

# 5. Test scripts on actual PR
./scripts/review-loop.sh           # Should show no unresolved reviews initially
./scripts/pr-completion-check.sh   # Should show PR status and blockers

# 6. Clean up test PR
gh pr close test/pr-workflow-setup
git checkout develop  # or your base branch
git branch -D test/pr-workflow-setup
```

**Verification Checklist:**

- [ ] Scripts execute without permission errors
- [ ] `gh auth status` shows authenticated user
- [ ] `gh pr view` works (when on PR branch) or errors gracefully (when not)
- [ ] `jq --version` shows installed version
- [ ] Scripts return proper JSON with `--json` flag
- [ ] Scripts return proper exit codes (0 = success, 1 = blockers, 2 = error)
- [ ] Test PR creation and script execution work end-to-end

## Quick Reference Table

**Common Scenarios - Quick Lookup:**

| Scenario | Action | Command |
|----------|--------|---------|
| Base branch is `main` not `develop` | Update script line 122-123 | `git fetch origin main` |
| Use merge (not squash) | Update WARP.md merge command | `gh pr merge --auto --merge` |
| Multiple approvals required | Update pr-completion-check.sh | See "Custom Approval Requirements" below |
| External CI (not GitHub Actions) | Update CI check logic | Query your CI API in script |
| Monorepo structure | Place scripts at root | Keep shared at `/scripts/` |
| GitLab instead of GitHub | Replace `gh` CLI calls | Use GitLab API directly |

## Project-Specific Customizations

### For Different Languages/Frameworks

#### Node.js/JavaScript Projects

Update `docs/pr-completion-workflow.md` Phase 1:

```markdown
### Phase 1: Code Changes

- [ ] Run tests locally: `npm test`
- [ ] Run linting: `npm run lint`
- [ ] Run type checking: `npm run typecheck` (if TypeScript)
```

#### Python Projects

```markdown
### Phase 1: Code Changes

- [ ] Run tests locally: `pytest`
- [ ] Run linting: `ruff check .` or `flake8`
- [ ] Run type checking: `mypy .`
```

#### Go Projects

```markdown
### Phase 1: Code Changes

- [ ] Run tests locally: `go test ./...`
- [ ] Run linting: `golangci-lint run`
- [ ] Run formatting: `gofmt -w .`
```

### For Different CI Systems

#### GitLab CI

Update scripts to use GitLab API instead of GitHub:

```bash
# Replace gh CLI calls with GitLab API
# Example for review-loop.sh:
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  "https://gitlab.com/api/v4/projects/$PROJECT_ID/merge_requests/$MR_IID/discussions"
```

#### Jenkins/CircleCI/Travis

Update `pr-completion-check.sh` to check your CI system's API instead of GitHub Actions.

### For Monorepos

If you have a monorepo with multiple projects, you might want to:

1. **Share scripts at root level**:
   ```bash
   /scripts/review-loop.sh          # Shared
   /scripts/pr-completion-check.sh  # Shared
   /packages/project-a/docs/        # Project-specific docs
   /packages/project-b/docs/        # Project-specific docs
   ```

2. **Customize per package**:
   Each package can have its own `WARP.md` that references the shared scripts

## Advanced Customizations

### Custom Merge Strategies

If you don't use squash merging:

```bash
# Update WARP.md instructions
gh pr merge --auto --merge    # Regular merge
gh pr merge --auto --rebase   # Rebase merge
```

### Multiple Base Branches

If you use feature branches off different bases:

```bash
# Update pr-completion-check.sh to detect base branch dynamically
BASE_BRANCH=$(gh pr view --json baseRefName --jq '.baseRefName')
git fetch origin "$BASE_BRANCH" --quiet 2>/dev/null || true
BEHIND_COUNT=$(git rev-list --count "HEAD..origin/$BASE_BRANCH" 2>/dev/null || echo "0")
```

### Custom Approval Requirements

If you require multiple approvals:

```bash
# Update pr-completion-check.sh to check approval count
APPROVALS_REQUIRED=2
APPROVALS_COUNT=$(gh api repos/OWNER/REPO/pulls/PR_NUMBER/reviews \
  --jq '[.[] | select(.state == "APPROVED")] | length')
```

### Slack/Discord Notifications

Add notification hooks to scripts:

```bash
# At the end of pr-completion-check.sh
if [ ${#BLOCKERS[@]} -eq 0 ]; then
  curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"PR #'$PR_NUMBER' is ready to merge!"}' \
    $SLACK_WEBHOOK_URL
fi
```

## Troubleshooting

### Scripts Don't Execute

**Symptom:** `Permission denied` or `command not found` errors

**Solutions:**
```bash
# 1. Ensure scripts are executable
chmod +x scripts/*.sh

# 2. Verify shebang line (should be #!/bin/bash)
head -1 scripts/review-loop.sh

# 3. Check if bash is available
which bash

# 4. Try running with explicit bash
bash scripts/review-loop.sh
```

### GraphQL API Permissions

**Symptom:** `gh api graphql` returns authentication errors or `Bad credentials`

**Solutions:**
```bash
# 1. Check authentication status
gh auth status

# 2. Refresh authentication with repo scope
gh auth refresh -s repo

# 3. If using token, verify it has 'repo' scope
gh auth token | cut -d. -f2 | base64 -d | jq .scope  # On Linux/Mac with base64
# Should include "repo" in the output

# 4. Re-authenticate if needed
gh auth login
```

**Example Error:**
```
gh: Bad credentials
```

**Fix:** Run `gh auth refresh -s repo` or `gh auth login`

### Branch Protection Conflicts

**Symptom:** `gh pr merge --admin --squash` fails even with admin rights

**Solutions:**
1. **Check bypass settings:**
   - Go to: Settings → Branches → [your-base-branch]
   - Disable "Do not allow bypassing the above settings" if you want admin override
   
2. **Alternative approach:**
   - Enable "Require approval of most recent push"
   - Have another user approve after your changes
   - Then merge normally with `gh pr merge --auto --squash`

**Example Error:**
```
gh: You don't have permission to merge this pull request
```

**Fix:** Adjust branch protection rules or get another user's approval

### Script Returns Wrong Exit Code

**Symptom:** Script says "ready to merge" but GitHub shows blockers

**Solutions:**
```bash
# 1. Verify you're on the PR branch
git branch --show-current
gh pr view --json headRefName

# 2. Get fresh PR data
gh pr view --json mergeable,mergeStateStatus,reviewDecision

# 3. Check for stale git state
git fetch origin
git status

# 4. Run script with debug output
bash -x scripts/pr-completion-check.sh
```

### CI Check Names Don't Match

**Symptom:** Script reports CI passing but GitHub shows pending checks

**Note:** The script automatically detects CI checks via `gh pr checks`. This is usually accurate.

**If you need to verify:**
```bash
# List actual check names from GitHub
gh pr checks --json name,state,conclusion

# Compare with script output
./scripts/pr-completion-check.sh --json | jq '.status.ci_passing'
```

**If checks are from external CI (not GitHub Actions):**
- Update `pr-completion-check.sh` to query your CI system's API
- Or ensure external CI reports status back to GitHub via Commit Status API

## Agent-Specific Integration

### WARP (warp.dev)

If you use Warp's persistent rules feature, add these rules to your Warp settings:

```markdown
**Rule: PR Review-First Protocol**
When working on an existing PR, ALWAYS check for reviews first using ./scripts/review-loop.sh before any other action. If reviews exist, fix them immediately, resolve threads via GraphQL, and loop back to check again.

**Rule: PR Completion Goal**
When user says "continue" or "work on PR", the goal is a MERGED PR, not just "ready for review". Follow all phases through to merge execution.

**Rule: Review Thread Resolution**
After fixing review comments, always explicitly resolve threads using GraphQL API. Never assume threads auto-resolve.
```

**Or add directly to `WARP.md` in your project root** (WARP reads this automatically).

### GitHub Copilot Chat

GitHub Copilot Chat reads repository documentation. Ensure:
1. Your `WARP.md` or `README.md` contains the PR protocol
2. Or create `.github/copilot-instructions.md` with the protocol
3. Agents will reference this when you ask about PRs

### Cursor / Claude Desktop

**For Cursor:**
- Add to `.cursorrules` file (Cursor-specific format)
- Or add to `CLAUDE.md` in project root

**For Claude Desktop:**
- Add to `.claude/` directory
- Or include in project root documentation files

**Example `.cursorrules` format:**
```markdown
When working on an existing PR:
1. Always run ./scripts/review-loop.sh first
2. Fix any review comments immediately
3. Resolve threads via GraphQL API
4. Check PR completion with ./scripts/pr-completion-check.sh
5. Goal is MERGED PR, not just "ready for review"
```

## Maintenance

### Keeping Scripts Updated

When updating these scripts in your source project (yelp_search_demo), propagate changes:

```bash
# Copy updated scripts to other projects
for project in ~/projects/*/; do
  if [ -f "$project/scripts/review-loop.sh" ]; then
    cp scripts/review-loop.sh "$project/scripts/"
    cp scripts/pr-completion-check.sh "$project/scripts/"
    echo "Updated: $project"
  fi
done
```

### Version Tracking

Track which version of the workflow each project uses for easier updates:

**Format:**
```markdown
<!-- PR Workflow Version: 1.0.0 (from yelp_search_demo @ 2025-10-28) -->
```

**Where to add:**
- At the top of `WARP.md` (or your agent instruction file)
- Or in `docs/sharing-pr-workflow.md` itself

**Version format:** `MAJOR.MINOR.PATCH`
- `MAJOR`: Breaking changes requiring script/directory updates
- `MINOR`: New features or new customization points
- `PATCH`: Bug fixes or documentation clarifications

**Example versions:**
- `1.0.0`: Initial release
- `1.1.0`: Added support for monorepos
- `1.1.1`: Fixed base branch detection bug
- `2.0.0`: Rewrote scripts to support GitLab

## Template Repository

For easiest replication, create a template repository with:

```
template-pr-workflow/
├── docs/
│   ├── pr-completion-workflow.md
│   └── review-first-autopilot.md
├── scripts/
│   ├── review-loop.sh
│   └── pr-completion-check.sh
├── .github/
│   └── branch-protection-config.yml (documentation)
└── WARP.md (template section)
```

Then use GitHub's "Use this template" feature or:

```bash
# Clone and copy to new project
git clone git@github.com:your-org/template-pr-workflow.git /tmp/pr-workflow
cp -r /tmp/pr-workflow/{docs,scripts} /path/to/new/project/
cat /tmp/pr-workflow/WARP.md >> /path/to/new/project/WARP.md
```

## Success Indicators

After implementing this workflow, you should observe:

- ✅ Agents autonomously address review feedback
- ✅ Review threads are explicitly resolved in GitHub
- ✅ Fewer "continue" or "what's next?" prompts needed
- ✅ PRs complete through to merge without manual intervention
- ✅ Faster PR turnaround time
- ✅ More consistent PR completion behavior

## Support and Evolution

This workflow was developed iteratively based on real PR experiences. As you use it:

1. **Track metrics** - Monitor prompt reduction, completion rate
2. **Gather feedback** - Note when agents still need prompting
3. **Update documentation** - Improve based on actual usage patterns
4. **Share improvements** - Contribute back to source project

## Example Migration Script

Complete script to set up in a new project:

```bash
#!/bin/bash
# setup-pr-workflow.sh - Migrate PR workflow to new project
# Usage: ./setup-pr-workflow.sh [source-project-path]

set -e

SOURCE_PROJECT="${1:-}"
TARGET_PROJECT="$(pwd)"

# Validate source project
if [ -z "$SOURCE_PROJECT" ] || [ ! -d "$SOURCE_PROJECT" ]; then
  echo "❌ Error: Source project path required"
  echo "Usage: $0 /path/to/yelp_search_demo"
  exit 1
fi

# Verify required files exist in source
REQUIRED_FILES=(
  "$SOURCE_PROJECT/docs/pr-completion-workflow.md"
  "$SOURCE_PROJECT/docs/review-first-autopilot.md"
  "$SOURCE_PROJECT/scripts/git-sync.sh"
  "$SOURCE_PROJECT/scripts/sync-branch.sh"
  "$SOURCE_PROJECT/scripts/review-loop.sh"
  "$SOURCE_PROJECT/scripts/pr-completion-check.sh"
  "$SOURCE_PROJECT/WARP.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "❌ Error: Required file not found: $file"
    exit 1
  fi
done

echo "🔄 Setting up PR workflow in $TARGET_PROJECT"

# Create directories
mkdir -p docs scripts

# Copy files
echo "📄 Copying documentation..."
cp "$SOURCE_PROJECT/docs/pr-completion-workflow.md" docs/
cp "$SOURCE_PROJECT/docs/review-first-autopilot.md" docs/

echo "📜 Copying scripts..."
cp "$SOURCE_PROJECT/scripts/git-sync.sh" scripts/
cp "$SOURCE_PROJECT/scripts/sync-branch.sh" scripts/
cp "$SOURCE_PROJECT/scripts/review-loop.sh" scripts/
cp "$SOURCE_PROJECT/scripts/pr-completion-check.sh" scripts/
chmod +x scripts/*.sh

# Verify scripts are executable
if [ ! -x "scripts/git-sync.sh" ] || [ ! -x "scripts/sync-branch.sh" ] || [ ! -x "scripts/review-loop.sh" ] || [ ! -x "scripts/pr-completion-check.sh" ]; then
  echo "⚠️  Warning: Scripts may not be executable, fixing..."
  chmod +x scripts/*.sh
fi

# Copy optional GitHub Actions workflows
echo "⚙️  Copying optional GitHub Actions workflows..."
mkdir -p .github/workflows

if [ -f "$SOURCE_PROJECT/.github/workflows/auto-update-prs.yml" ]; then
  cp "$SOURCE_PROJECT/.github/workflows/auto-update-prs.yml" .github/workflows/
  echo "   ✅ Copied auto-update-prs.yml (update base branch name if needed)"
else
  echo "   ⚠️  auto-update-prs.yml not found in source (optional)"
fi

if [ -f "$SOURCE_PROJECT/.github/workflows/cleanup-merged-branches.yml" ]; then
  cp "$SOURCE_PROJECT/.github/workflows/cleanup-merged-branches.yml" .github/workflows/
  echo "   ✅ Copied cleanup-merged-branches.yml (update base branches if needed)"
else
  echo "   ⚠️  cleanup-merged-branches.yml not found in source (optional)"
fi

echo ""
echo "   💡 Remember to enable GitHub auto-delete in repository settings:"
echo "      Settings → General → Pull Requests → Enable 'Automatically delete head branches'"

# Update agent instructions
echo "📝 Updating agent instructions..."
AGENT_FILE="WARP.md"
if [ ! -f "$AGENT_FILE" ]; then
  echo "# Project Instructions" > "$AGENT_FILE"
fi

# Extract PR protocol section from source (between ## markers)
if grep -q "^## 🔄 PR COMPLETION PROTOCOL" "$SOURCE_PROJECT/WARP.md"; then
  sed -n '/^## 🔄 PR COMPLETION PROTOCOL/,/^## /p' "$SOURCE_PROJECT/WARP.md" \
    | sed '$ d' >> "$AGENT_FILE"
  echo "" >> "$AGENT_FILE"
else
  echo "⚠️  Warning: Could not find PR protocol in source WARP.md"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "⚠️  REQUIRED NEXT STEPS:"
echo "1. Update scripts/git-sync.sh:"
echo "   - Line 28, 38: Change 'develop' to your base branch name if different"
echo "2. Update scripts/sync-branch.sh:"
echo "   - Line 224: Change default from 'main' to your base branch if different"
echo "3. Update scripts/pr-completion-check.sh:"
echo "   - Line 122-123: Change 'develop' to your base branch name"
echo "   - Line 252: Update sync command if different"
echo "4. Update .github/workflows/auto-update-prs.yml (if copied):"
echo "   - Line 6: Change 'develop' to your base branch name"
echo "5. Update .github/workflows/cleanup-merged-branches.yml (if copied):"
echo "   - Lines 7-8: Update base branches list if different"
echo "   - Enable GitHub setting: Settings → General → Pull Requests → 'Automatically delete head branches'"
echo "6. Review and customize docs/pr-completion-workflow.md (update base branch, test commands)"
echo "7. Configure GitHub branch protection rules:"
echo "   https://github.com/[owner]/[repo]/settings/branches"
echo "8. Test setup:"
echo "   ./scripts/git-sync.sh          # Test session sync"
echo "   ./scripts/review-loop.sh --json"
echo "   ./scripts/pr-completion-check.sh --json"
echo "9. Create test PR and verify workflow end-to-end"
echo ""
echo "📚 Documentation: docs/sharing-pr-workflow.md"
```

**To use:**
```bash
# From your target project directory
./setup-pr-workflow.sh /path/to/yelp_search_demo
```

## Resources

- **Source Project**: yelp_search_demo
- **Issue**: #953 (original feature request)
- **Implementation PR**: #954
- **GitHub GraphQL API**: https://docs.github.com/en/graphql
- **GitHub CLI**: https://cli.github.com/

---

*Last updated: 2025-10-28*  
*Workflow Version: 1.0.0*
