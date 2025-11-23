# Dependabot Auto-Merge Configuration Changes

## Problem
Dependabot PRs were not merging automatically without human intervention, despite being configured for auto-merge.

## Root Causes Identified
1. **Missing Dependabot Auto-Merge Configuration**: The `.github/dependabot.yml` file lacked proper auto-merge settings
2. **Overly Restrictive Conditions**: Auto-merge was only enabled for patch updates, excluding minor updates for development dependencies
3. **Workflow Conflicts**: Multiple workflows handling the same functionality with conflicting logic
4. **Unused Scripts**: The `poll-pr-status.js` script was attempting to handle auto-merge but wasn't integrated properly

## Changes Made

### 1. Updated Dependabot Configuration (`.github/dependabot.yml`)
- Added `open-pull-requests-limit: 10` to prevent too many concurrent PRs
- Added `allow` sections to specify which types of updates can be auto-merged:
  - Production dependencies: only security updates
  - Development dependencies: all updates (patch, minor, major)

### 2. Created Dedicated Auto-Merge Workflow (`.github/workflows/dependabot-auto-merge.yml`)
- **Trigger**: `pull_request_target` events for better security and permissions
- **Auto-approval**: Automatically approves all Dependabot PRs
- **Auto-merge conditions**:
  - ✅ All patch updates (`version-update:semver-patch`)
  - ✅ Minor updates for development dependencies
  - ✅ All development dependency updates
  - ❌ Major updates (require manual review)
  - ❌ Minor updates for production dependencies (require manual review)
- **Feedback**: Comments on PRs that require manual review with clear instructions

### 3. Cleaned Up Existing Workflows
- Removed auto-merge logic from `auto-pr-management.yml` to avoid conflicts
- Kept the auto-update functionality for non-Dependabot PRs
- Removed unused `poll-pr-status.js` script

### 4. Safety Measures Maintained
- Branch protection rules still apply
- CI tests must pass before auto-merge occurs
- Security updates are handled carefully
- Major updates always require manual review

## Expected Behavior

### Will Auto-Merge:
- Patch updates for any dependency (e.g., `1.2.3` → `1.2.4`)
- Minor updates for development/test dependencies (e.g., `1.2.0` → `1.3.0` for gems in `:development` group)
- Any updates to development-only dependencies

### Will Require Manual Review:
- Major updates (e.g., `1.0.0` → `2.0.0`)
- Minor updates for production dependencies (e.g., `rails 7.0.0` → `rails 7.1.0`)

### Process Flow:
1. Dependabot creates PR
2. Auto-merge workflow triggers
3. PR is automatically approved
4. Auto-merge is enabled (if conditions met)
5. Once CI passes, GitHub automatically merges the PR
6. If manual review needed, a comment is added explaining why

## Testing
To test the new configuration:
1. Wait for Dependabot to create new PRs, or
2. Manually trigger Dependabot updates: `@dependabot rebase` in an existing PR
3. Monitor the workflow runs in GitHub Actions tab
4. Verify auto-merge is enabled on qualifying PRs

## Monitoring
- Check GitHub Actions logs for workflow execution
- Monitor Dependabot PR comments for auto-merge status
- Review merged PRs to ensure only appropriate updates are auto-merged
