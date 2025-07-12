# Branch Synchronization Scripts

This directory contains orchestration CLI scripts for managing branch workflows.

## sync-branch.sh

### Overview
Implements **Step 3: Branch synchronization** in the orchestration CLI. This script automatically synchronizes your current feature branch with the base branch (default: `main`).

### Features

1. **Branch Status Detection**
   - Primary method: Uses `gh api` to check if local branch is behind `origin/main`
   - Fallback method: Uses `git fetch && git status` when GitHub CLI is unavailable
   - Supports detection of: ahead, behind, identical, and diverged states

2. **Auto-merge Functionality**
   - When branch is behind, automatically executes: `mise exec -- git merge origin/main`
   - Uses `--no-edit` flag for automated commits
   - Always prefixes commands with `mise exec --` for environment consistency

3. **Push Updates and Verification**
   - Pushes updates to remote after successful merge
   - Verifies push success by comparing local and remote commit SHAs
   - Uses explicit status checks for reliability

4. **Conflict Handling**
   - Detects merge conflicts during auto-merge process
   - Automatically aborts conflicted merges with `git merge --abort`
   - Surfaces detailed conflict information:
     - Lists conflicting files with `git diff --name-only`
     - Shows diff statistics with `git diff --stat`
     - Displays current git status for manual resolution guidance

5. **Coding Standards Enforcement**
   - Integrates with `lefthook.yml` pre-commit hooks
   - Runs `make` commands for additional quality checks
   - Follows project coding standards automatically

### Usage

```bash
# Sync with origin/main (default)
./scripts/sync-branch.sh

# Sync with origin/develop
./scripts/sync-branch.sh develop

# Sync with origin/master
./scripts/sync-branch.sh master

# Show help
./scripts/sync-branch.sh --help
```

### Environment Variables

- `GITHUB_TOKEN`: GitHub personal access token (optional)
  - When provided, enables GitHub CLI API for faster branch status detection
  - When not available, automatically falls back to git commands

### Requirements

- Git repository with remote origin
- `mise` tool for environment management
- Current branch must be a feature branch (not the base branch)

### Error Handling

The script provides comprehensive error handling:

- **Not in git repository**: Exits with error message
- **On base branch**: Prevents self-sync attempts
- **Merge conflicts**: Aborts merge and shows conflict details
- **Push failures**: Reports specific push errors
- **Verification failures**: Alerts on mismatched commits

### Integration

This script integrates seamlessly with:

- **lefthook.yml**: Automatic coding standards enforcement
- **Makefile**: Additional lint and test commands
- **mise**: Environment and tool management
- **GitHub CLI**: Enhanced branch status detection
- **pr-lifecycle.sh**: Part of larger orchestration workflow

### Example Output

```
[INFO] Starting branch synchronization...
[INFO] Current branch: feature/new-feature
[INFO] Base branch: main
[INFO] Checking if 'feature/new-feature' is behind 'origin/main'
[WARNING] Branch 'feature/new-feature' is behind 'origin/main'
[INFO] Auto-merging 'origin/main' into 'feature/new-feature'
[SUCCESS] Successfully merged 'origin/main' into 'feature/new-feature'
[SUCCESS] Auto-merge completed successfully
[INFO] Pushing updates to 'origin/feature/new-feature'...
[SUCCESS] Successfully pushed to 'origin/feature/new-feature'
[INFO] Verifying push...
[SUCCESS] Push verification successful
[INFO] Enforcing coding standards...
[SUCCESS] Coding standards check passed
[SUCCESS] Branch synchronization completed successfully!
```

## pr-lifecycle.sh

Enhanced PR lifecycle management script with integrated branch synchronization capabilities.

### Usage

```bash
# Create a new PR
./scripts/pr-lifecycle.sh trigger feature/new-feature "Add new feature" "Description"

# Check PR status
./scripts/pr-lifecycle.sh poll 123

# Sync branch (enhanced with new functionality)
./scripts/pr-lifecycle.sh sync main
```

For detailed usage, run: `./scripts/pr-lifecycle.sh --help`
