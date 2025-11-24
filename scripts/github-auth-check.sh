#!/bin/bash
# scripts/github-auth-check.sh
#
# Shared helper for scripts that talk to GitHub.
# Behavior:
# - If GITHUB_TOKEN is set, assume authentication is OK.
# - Otherwise, require `gh` to be installed and authenticated.
# - Emits clear, user-friendly errors and exits non-zero on failure.
#
# Usage (bash):
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   # shellcheck source=github-auth-check.sh
#   . "${SCRIPT_DIR}/github-auth-check.sh"
#   ensure_github_auth            # human output
#   ensure_github_auth "json"    # JSON-safe error output

set -euo pipefail

ensure_github_auth() {
  local mode="${1:-human}"  # "human" or "json"

  # If a token is explicitly provided, trust it and return.
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    return 0
  fi

  # No token; fall back to GitHub CLI auth.
  if ! command -v gh >/dev/null 2>&1; then
    if [[ "$mode" == "json" ]]; then
      echo '{"error": "GitHub CLI (gh) is not available and GITHUB_TOKEN is not set."}'
    else
      echo "❌ GitHub CLI (gh) is not available and GITHUB_TOKEN is not set." >&2
    fi
    exit 1
  fi

  if ! gh auth status >/dev/null 2>&1; then
    if [[ "$mode" == "json" ]]; then
      echo '{"error": "GitHub CLI is not authenticated. Run gh auth login or set GITHUB_TOKEN."}'
    else
      echo "❌ GitHub CLI is not authenticated. Run 'gh auth login' or set GITHUB_TOKEN." >&2
    fi
    exit 1
  fi
}
