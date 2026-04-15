#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "❌ Error: Branch name required"
  echo "Usage: ./workflow-new-feature.sh <branch-name>"
  echo "Example: ./workflow-new-feature.sh fix/bug-123"
  exit 1
fi

branch_name="$1"
echo "🌿 Creating new feature branch: $branch_name"

# Simple workflow without external dependencies
current_branch=$(git branch --show-current)
if [ "$current_branch" != "develop" ] && [ "$current_branch" != "main" ]; then
  echo "📍 Switching to develop first..."
  git switch develop
fi

echo "🔄 Pulling latest changes..."
git pull --ff-only origin develop

echo "✅ Creating branch: $branch_name"
git switch -c "$branch_name"

echo "🎉 Successfully created and switched to branch: $branch_name"
echo "   You can now make your changes and commit them."
