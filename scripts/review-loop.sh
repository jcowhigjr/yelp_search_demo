#!/bin/bash
# scripts/review-loop.sh
#
# Check for unresolved review threads on the current PR
# Usage: ./scripts/review-loop.sh [--json]
#
# Exit codes:
#   0 - No unresolved threads
#   1 - Unresolved threads found
#   2 - Error (not on a PR branch, gh CLI issues, etc.)

set -e

# Parse arguments
OUTPUT_JSON=false
if [[ "$1" == "--json" ]]; then
  OUTPUT_JSON=true
fi

# Check if we're on a branch with a PR
if ! gh pr view &>/dev/null; then
  if [[ "$OUTPUT_JSON" == "true" ]]; then
    echo '{"error": "Not on a branch with an open PR", "unresolved_count": null}'
  else
    echo "❌ Not on a branch with an open PR"
  fi
  exit 2
fi

# Get PR and repo info
PR_NUMBER=$(gh pr view --json number --jq '.number')
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')

if [[ "$OUTPUT_JSON" == "false" ]]; then
  echo "🔄 Checking for review threads on PR #$PR_NUMBER..."
fi

# Query for review threads
REVIEW_DATA=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            isOutdated
            comments(first: 10) {
              nodes {
                databaseId
                body
                path
                line
                startLine
                author {
                  login
                }
                createdAt
              }
            }
          }
        }
      }
    }
  }
' -f owner="$REPO_OWNER" -f repo="$REPO_NAME" -F number="$PR_NUMBER")

# Parse unresolved threads
UNRESOLVED=$(echo "$REVIEW_DATA" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)]')
COUNT=$(echo "$UNRESOLVED" | jq 'length')

if [[ "$OUTPUT_JSON" == "true" ]]; then
  # JSON output
  echo "$UNRESOLVED" | jq --arg count "$COUNT" '{
    unresolved_count: ($count | tonumber),
    threads: [.[] | {
      thread_id: .id,
      outdated: .isOutdated,
      comments: [.comments.nodes[] | {
        comment_id: .databaseId,
        author: .author.login,
        body: .body,
        file: .path,
        line: .line,
        start_line: .startLine,
        created_at: .createdAt
      }]
    }]
  }'
else
  # Human-readable output
  if [[ "$COUNT" -eq 0 ]]; then
    echo "✅ No unresolved review threads"
    exit 0
  fi

  echo "⚠️  Found $COUNT unresolved review thread(s)"
  echo ""
  echo "Review comments to address:"
  echo ""
  
  echo "$UNRESOLVED" | jq -r '.[] | "
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Thread ID: \(.id)
Author:    \(.comments.nodes[0].author.login)
File:      \(.comments.nodes[0].path // "N/A")
Line:      \(.comments.nodes[0].line // "N/A")
Created:   \(.comments.nodes[0].createdAt)

Comment:
\(.comments.nodes[0].body)
"'
fi

# Exit with status indicating unresolved threads
if [[ "$COUNT" -gt 0 ]]; then
  exit 1
else
  exit 0
fi
