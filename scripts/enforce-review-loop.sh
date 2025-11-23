#!/bin/bash
# scripts/enforce-review-loop.sh
#
# Wrapper around scripts/review-loop.sh used by git hooks to ensure
# unresolved review threads block pushes only when the current branch
# has an open pull request.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REVIEW_LOOP_SCRIPT="$REPO_ROOT/scripts/review-loop.sh"

if ! command -v gh >/dev/null 2>&1; then
  echo "⚠️  review-loop enforcement skipped: GitHub CLI (gh) is not installed."
  exit 0
fi

if ! gh pr view &>/dev/null; then
  echo "ℹ️  review-loop enforcement: no open PR detected for this branch; skipping."
  exit 0
fi

if "$REVIEW_LOOP_SCRIPT"; then
  exit 0
fi

echo "❌ Unresolved review threads detected. Please address, reply, and resolve each thread before pushing."
echo "💡 Hint: If you are pushing the fix for these reviews, you can bypass this check with: git push --no-verify"
exit 1
