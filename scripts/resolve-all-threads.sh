#!/bin/bash
# scripts/resolve-all-threads.sh [--force]
#
# Resolves every unresolved review thread on the current PR after confirmation.

set -euo pipefail

FORCE=false
if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
fi

# Prefer MCP GitHub tools from agents when available; this script is a CLI fallback.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=github-auth-check.sh
. "${SCRIPT_DIR}/github-auth-check.sh"

ensure_github_auth "human"

if ! gh pr view &>/dev/null; then
  echo "❌ No open PR detected for this branch." >&2
  exit 1
fi

PR_NUMBER=$(gh pr view --json number --jq '.number')
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')

REVIEW_DATA=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 5) {
              nodes {
                author { login }
                body
                path
                line
              }
            }
          }
        }
      }
    }
  }
' -f owner="$REPO_OWNER" -f repo="$REPO_NAME" -F number="$PR_NUMBER")

THREADS=$(echo "$REVIEW_DATA" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)]')
COUNT=$(echo "$THREADS" | jq 'length')

if [[ "$COUNT" -eq 0 ]]; then
  echo "✅ No unresolved review threads found."
  exit 0
fi

echo "⚠️  Resolving $COUNT review thread(s) on PR #$PR_NUMBER."
if [[ "$FORCE" == "false" ]]; then
  echo "Listing threads before resolving:"
  echo "$THREADS" | jq -r '.[] | "\nID: \(.id)\nAuthor: \(.comments.nodes[0].author.login)\nFile: \(.comments.nodes[0].path // "N/A")\nLine: \(.comments.nodes[0].line // "N/A")\nComment: \(.comments.nodes[0].body)\n"'
  read -rp "Resolve all listed threads? (y/N) " CONFIRM
  if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted."
    exit 1
  fi
fi

SUCCESS=0
FAILED=0

for THREAD_ID in $(echo "$THREADS" | jq -r '.[].id'); do
  if gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"$THREAD_ID\"}) { thread { id isResolved } } }" >/dev/null; then
    echo "✅ Resolved $THREAD_ID"
    SUCCESS=$((SUCCESS + 1))
  else
    echo "❌ Failed to resolve $THREAD_ID" >&2
    FAILED=$((FAILED + 1))
  fi
done

echo "Summary: $SUCCESS resolved, $FAILED failed."
if [[ "$FAILED" -gt 0 ]]; then
  exit 1
fi
