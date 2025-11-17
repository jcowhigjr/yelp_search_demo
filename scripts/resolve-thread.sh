#!/bin/bash
# scripts/resolve-thread.sh THREAD_ID
#
# Resolves a single GitHub review thread via GraphQL.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 THREAD_ID" >&2
  exit 1
fi

THREAD_ID="$1"

if ! command -v gh >/dev/null 2>&1; then
  echo "❌ GitHub CLI (gh) is required to resolve review threads." >&2
  exit 1
fi

RESPONSE=$(gh api graphql -f query="mutation ResolveThread { resolveReviewThread(input: {threadId: \"$THREAD_ID\"}) { thread { id isResolved } } }")

if [[ $(echo "$RESPONSE" | jq -r '.data.resolveReviewThread.thread.isResolved') == "true" ]]; then
  echo "✅ Thread $THREAD_ID resolved."
else
  echo "⚠️  Unable to confirm resolution for thread $THREAD_ID." >&2
  echo "$RESPONSE"
  exit 1
fi
