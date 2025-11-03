#!/usr/bin/env bash

set -euo pipefail

# Determine the reference to compare against for the upcoming push.
DIFF_BASE=""

if git rev-parse --verify HEAD@{upstream} >/dev/null 2>&1; then
  DIFF_BASE="HEAD@{upstream}"
elif git rev-parse --verify origin/develop >/dev/null 2>&1; then
  DIFF_BASE="$(git merge-base HEAD origin/develop 2>/dev/null || true)"
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

# Gather changed files (including deletions) between DIFF_BASE and HEAD.
mapfile -d '' -t CHANGED_FILES < <(git diff --name-only --diff-filter=ACDMR -z "${DIFF_BASE}..HEAD")

SAFE_PATTERNS=(
  '^docs/'
  '^\\.github/'
  '^README\\.md$'
  '^LICENSE$'
  '^WARP\\.md$'
  '^\\.rubocop\\.yml$'
  '^\\.rubocop_todo\\.yml$'
  '^\\.erb_lint\\.yml$'
  '^\\.better-html\\.yml$'
  '^\\.solargraph\\.yml$'
  '^\\.prettier'
  '^cspell\\.config\\.yaml$'
  '^\\.gitignore$'
  '^CODEOWNERS$'
  '^\\.yarnrc\\.yml$'
  '^static-analysis\\.datadog\\.yml$'
  '^agent\\.prompt\\.yml$'
  '^\\.pr-workflow\\.yml$'
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
