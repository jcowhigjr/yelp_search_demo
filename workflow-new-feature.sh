#!/bin/bash
set -e

if [[ -z "$1" ]]; then
  echo "❌ Error: Branch name required"
  echo "Usage: lefthook run workflow-new-feature <branch-name>"
  echo "Example: lefthook run workflow-new-feature fix/bug-123"
  exit 1
fi

branch_name="$1"
echo "🌿 Creating new feature branch: $branch_name"

# Check if on main/develop
current_branch=$(git branch --show-current)
if [[ "$current_branch" != "develop" && "$current_branch" != "main" ]]; then
  echo "⚠️  Currently on branch: $current_branch"
  echo "   Switching to develop first..."
  git checkout develop
fi

# Pull latest
echo "🔄 Pulling latest changes..."
git pull --ff --no-edit origin develop

# Create and switch to new branch
echo "✅ Creating branch: $branch_name"
git checkout -b "$branch_name"

echo "🎉 Successfully created and switched to branch: $branch_name"
echo "   You can now make your changes and commit them."
