#!/usr/bin/env bash

set -euo pipefail

# Determine the reference to compare against for the upcoming push.
DIFF_BASE=""

if git rev-parse --verify HEAD@{upstream} >/dev/null 2>&1; then
  DIFF_BASE="HEAD@{upstream}"
elif git rev-parse --verify origin/develop >/dev/null 2>&1; then
  DIFF_BASE="$(git merge-base HEAD origin/develop 2>/dev/null)"
  if [[ -z "$DIFF_BASE" ]]; then
    echo "ℹ️  Unable to determine upstream comparison point."
    echo "   Running system tests by default."
    exit 1
  fi
elif git rev-parse --verify HEAD^ >/dev/null 2>&1; then
  DIFF_BASE="HEAD^"
else
  echo "ℹ️  Unable to determine upstream comparison point."
  echo "   Running system tests by default."
  exit 1
fi

if [[ "$DIFF_BASE" == "HEAD^" ]]; then
  echo "ℹ️  No upstream branch detected; comparing against the previous local commit."
fi

# Gather changed files (including deletions and renames) between DIFF_BASE and HEAD.
# Use --name-status to detect renames and check both source and destination paths.
CHANGED_FILES=()
while IFS=$'\t' read -r status file; do
  # For renames (R), check both old and new paths
  if [[ $status =~ ^R ]]; then
    # Status is like "R100" or "R095", file is "old_path<tab>new_path"
    # Split on tab to get both paths
    old_path="${file%%$'\t'*}"
    new_path="${file#*$'\t'}"
    CHANGED_FILES+=("$old_path" "$new_path")
  else
    CHANGED_FILES+=("$file")
  fi
done < <(git diff --name-status --diff-filter=ACDMR "${DIFF_BASE}..HEAD")

SAFE_PATTERNS=(
  '^docs/'
  '^\.github/'
  '^scripts/git-sync\.sh$'
  '^README\.md$'
  '^LICENSE$'
  '^WARP\.md$'
  '^pr_compliance_comment\.md$'
  '^\.rubocop\.yml$'
  '^\.rubocop_todo\.yml$'
  '^\.erb_lint\.yml$'
  '^\.better-html\.yml$'
  '^\.solargraph\.yml$'
  '^\.prettier'
  '^cspell\.config\.yaml$'
  '^\.gitignore$'
  '^CODEOWNERS$'
  '^\.yarnrc\.yml$'
  '^static-analysis\.datadog\.yml$'
  '^agent\.prompt\.yml$'
  '^\.pr-workflow\.yml$'
)

if ((${#CHANGED_FILES[@]} == 0)); then
  echo "✅ All changed files are safe (documentation/config only)"
  echo "   Skipping system tests to save time"
  exit 0
fi

for file in "${CHANGED_FILES[@]}"; do
  file_safe=false
  for pattern in "${SAFE_PATTERNS[@]}"; do
    if [[ $file =~ $pattern ]]; then
      file_safe=true
      break
    fi
  done

  if [[ $file_safe == false ]]; then
    echo "🧪 Changed files may affect system behavior"
    echo "   Running full system test suite"
    exit 1
  fi
done

echo "✅ All changed files are safe (documentation/config only)"
echo "   Skipping system tests to save time"
exit 0
