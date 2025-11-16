#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "❌ Error: Branch name required"
  echo "Usage: lefthook run workflow-new-feature <branch-name>"
  echo "Example: lefthook run workflow-new-feature fix/bug-123"
  exit 1
fi

branch_name="$1"
echo "🌿 Creating new feature branch: $branch_name"

# Simple workflow without external dependencies
current_branch=$(git branch --show-current)
if [ "$current_branch" != "develop" ] && [ "$current_branch" != "main" ]; then
  echo "📍 Switching to develop first..."
  git checkout develop
fi

echo "🔄 Pulling latest changes..."
git pull --ff-only origin develop

echo "✅ Creating branch: $branch_name"
git checkout -b "$branch_name"

echo "🎉 Successfully created and switched to branch: $branch_name"
echo "   You can now make your changes and commit them."
