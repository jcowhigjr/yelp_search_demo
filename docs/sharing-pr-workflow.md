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
- Provides actionable next steps

**Customization needed:**
- Line 123: Change `develop` to your base branch name
- Line 194-210: Update for your specific CI check names

**Target:** `scripts/pr-completion-check.sh`

```bash
chmod +x scripts/pr-completion-check.sh
```

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
cp /path/to/yelp_search_demo/scripts/review-loop.sh scripts/
cp /path/to/yelp_search_demo/scripts/pr-completion-check.sh scripts/

# Make executable
chmod +x scripts/review-loop.sh
chmod +x scripts/pr-completion-check.sh
```

### Step 4: Customize for Your Project

#### A. Update pr-completion-check.sh

Edit `scripts/pr-completion-check.sh`:

```bash
# Line 123: Change base branch
git fetch origin main --quiet 2>/dev/null || true  # If you use 'main' instead of 'develop'
BEHIND_COUNT=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")

# Line 242: Update sync command
echo "  • Sync branch: ./scripts/sync-branch.sh main"  # If you use 'main'
```

If you have custom CI check names, update the script to look for those.

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

Add to your project's agent instruction file (`WARP.md`, `CLAUDE.md`, etc.):

```markdown
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
5. **Push immediately** - Pre-push hooks validate; don't wait for remote CI
6. **Complete to merge** - Goal is merged PR, not just "ready for review"

### Documentation

- **Full workflow**: [docs/pr-completion-workflow.md](./docs/pr-completion-workflow.md)
- **Review loop details**: [docs/review-first-autopilot.md](./docs/review-first-autopilot.md)
- **Helper scripts**: `./scripts/review-loop.sh`, `./scripts/pr-completion-check.sh`
```

### Step 5: Configure Branch Protection

Ensure your GitHub repository has these branch protection rules enabled for your base branch:

```
Settings → Branches → Branch protection rules → Edit [your-base-branch]

Required:
✓ Require a pull request before merging
✓ Require conversation resolution before merging
✓ Require status checks to pass before merging
  - Add your CI check name (e.g., "test", "CI", "build")
✓ Require branches to be up to date before merging

Optional but recommended:
✓ Require review from Code Owners (if you have CODEOWNERS file)
✓ Require signed commits
✓ Require linear history
✓ Do not allow bypassing the above settings (for strict enforcement)
```

### Step 6: Test the Setup

Create a test PR to verify:

```bash
# 1. Create a test branch
git checkout -b test/pr-workflow-setup

# 2. Make a trivial change
echo "# Test PR Workflow" >> TEST.md
git add TEST.md
git commit -m "Test PR workflow setup"
git push -u origin test/pr-workflow-setup

# 3. Create PR
gh pr create --title "Test: PR Workflow Setup" --body "Testing autonomous PR completion workflow"

# 4. Test the scripts
./scripts/review-loop.sh           # Should show no unresolved reviews
./scripts/pr-completion-check.sh   # Should show PR status

# 5. Have someone add a review comment, then test the review loop
# 6. Clean up test PR
gh pr close && git checkout main && git branch -D test/pr-workflow-setup
```

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

```bash
# Ensure scripts are executable
chmod +x scripts/*.sh

# Check shebang line
head -1 scripts/review-loop.sh  # Should be #!/bin/bash
```

### GraphQL API Permissions

```bash
# Ensure gh CLI has proper scopes
gh auth status
gh auth refresh -s repo
```

### Branch Protection Conflicts

If admin merge fails even with admin rights:

1. Check "Do not allow bypassing" is disabled (if you want admin override)
2. Or enable "Require approval of most recent push" and have another user approve

### CI Check Names Don't Match

```bash
# List actual check names
gh pr checks --json name

# Update pr-completion-check.sh with actual names
```

## Integration with Warp Rules

If you use Warp's persistent rules feature, add these rules:

```markdown
**Rule: PR Review-First Protocol**
When working on an existing PR, ALWAYS check for reviews first using ./scripts/review-loop.sh before any other action. If reviews exist, fix them immediately, resolve threads via GraphQL, and loop back to check again.

**Rule: PR Completion Goal**
When user says "continue" or "work on PR", the goal is a MERGED PR, not just "ready for review". Follow all phases through to merge execution.

**Rule: Review Thread Resolution**
After fixing review comments, always explicitly resolve threads using GraphQL API. Never assume threads auto-resolve.
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

Consider tracking which version of the workflow each project uses:

```bash
# Add to each project's WARP.md
<!-- PR Workflow Version: 1.0.0 (from yelp_search_demo @ 2025-10-28) -->
```

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

SOURCE_PROJECT="/path/to/yelp_search_demo"
TARGET_PROJECT="$(pwd)"

echo "🔄 Setting up PR workflow in $TARGET_PROJECT"

# Create directories
mkdir -p docs scripts

# Copy files
echo "📄 Copying documentation..."
cp "$SOURCE_PROJECT/docs/pr-completion-workflow.md" docs/
cp "$SOURCE_PROJECT/docs/review-first-autopilot.md" docs/

echo "📜 Copying scripts..."
cp "$SOURCE_PROJECT/scripts/review-loop.sh" scripts/
cp "$SOURCE_PROJECT/scripts/pr-completion-check.sh" scripts/
chmod +x scripts/*.sh

echo "📝 Updating WARP.md..."
if [ ! -f "WARP.md" ]; then
  echo "# Project Instructions" > WARP.md
fi

# Extract PR protocol section from source
sed -n '/^## 🔄 PR COMPLETION PROTOCOL/,/^## /p' "$SOURCE_PROJECT/WARP.md" \
  | sed '$ d' >> WARP.md

echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and customize docs/pr-completion-workflow.md"
echo "2. Update scripts/pr-completion-check.sh for your base branch"
echo "3. Configure GitHub branch protection rules"
echo "4. Test with a sample PR"
echo ""
echo "Documentation: docs/sharing-pr-workflow.md"
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
