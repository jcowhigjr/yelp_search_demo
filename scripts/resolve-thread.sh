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

# Prefer MCP GitHub tools from agents when available; this script is a CLI fallback.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=github-auth-check.sh
. "${SCRIPT_DIR}/github-auth-check.sh"

ensure_github_auth "human"

RESPONSE=$(gh api graphql -f query="mutation ResolveThread { resolveReviewThread(input: {threadId: \"$THREAD_ID\"}) { thread { id isResolved } } }")

if [[ $(echo "$RESPONSE" | jq -r '.data.resolveReviewThread.thread.isResolved') == "true" ]]; then
  echo "✅ Thread $THREAD_ID resolved."
else
  echo "⚠️  Unable to confirm resolution for thread $THREAD_ID." >&2
  echo "$RESPONSE"
  exit 1
fi
