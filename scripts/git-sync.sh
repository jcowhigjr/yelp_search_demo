#!/bin/bash
# Simple git sync script - keeps your local repo fresh
# Updates develop branch and prunes merged branches

set -euo pipefail

echo "🔄 Syncing local repository with GitHub..."

# Save current branch
current_branch=$(git branch --show-current)
echo "📍 Current branch: $current_branch"

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "⚠️  You have uncommitted changes. Stashing them temporarily..."
    git stash push -m "git-sync auto-stash $(date +%Y-%m-%d-%H-%M-%S)"
    stashed=true
else
    stashed=false
fi

# Fetch all changes and prune deleted remote branches
echo "📥 Fetching latest changes..."
git fetch --prune origin

# Switch to develop and update it
echo "🔄 Updating develop branch..."
git checkout develop

# Try fast-forward first, if it fails reset to origin/develop
if ! git pull --ff-only origin develop 2>/dev/null; then
    echo "⚠️  Local develop has diverged from remote. Resetting to match origin/develop..."
    git reset --hard origin/develop
fi

# Clean up local branches that are already merged into develop
echo "🧹 Cleaning up merged branches..."
merged_branches=$(git branch --merged develop | grep -v "^\*" | grep -v "develop" | grep -v "main" || true)

if [ -n "$merged_branches" ]; then
    echo "   Deleting merged branches:"
    echo "$merged_branches" | while read -r branch; do
        echo "   - $branch"
        git branch -d "$branch" 2>/dev/null || true
    done
else
    echo "   No merged branches to clean up"
fi

# Return to original branch if it still exists
if git show-ref --verify --quiet "refs/heads/$current_branch"; then
    echo "🔙 Returning to branch: $current_branch"
    git checkout "$current_branch"
else
    echo "ℹ️  Original branch '$current_branch' was deleted (already merged)"
    echo "   Staying on develop"
    current_branch="develop"
fi

# Restore stashed changes if any
if [ "$stashed" = true ]; then
    echo "📦 Restoring your stashed changes..."
    if git stash pop; then
        echo "✅ Changes restored successfully"
    else
        echo "⚠️  Conflicts when restoring changes. Run 'git stash list' to see stashed changes."
    fi
fi

# Show summary
echo ""
echo "✅ Sync complete!"
echo "📊 Current status:"
git log --oneline -1
echo ""
