#!/usr/bin/env bash
# Daily Repo Health findings sweep (issue #3003).
#
# Prints findings as markdown on stdout. Prints nothing and exits 0 when the
# repository is healthy. Any gh/jq failure exits non-zero so drift detection
# fails loudly instead of silently skipping checks.
#
# Required env:
#   REPO    - owner/name of the repository to inspect
# Optional env:
#   GH_BIN  - gh-compatible CLI to invoke (default: gh; tests inject a stub)
set -euo pipefail

GH="${GH_BIN:-gh}"
REPO="${REPO:?set REPO to owner/name}"

# --- 1. Stranded auto-merge PRs (queued but BEHIND develop) ---
STRANDED=$("$GH" pr list --repo "$REPO" --state open --limit 50 \
  --json number,title,mergeStateStatus,autoMergeRequest \
  | jq '[.[] | select(.autoMergeRequest != null and .mergeStateStatus == "BEHIND")]')
if [ "$(echo "$STRANDED" | jq 'length')" -gt 0 ]; then
  echo "### Stranded auto-merge PRs (queued but BEHIND develop)"
  echo "$STRANDED" | jq -r '.[] | "- #\(.number) \(.title)"'
  echo ""
fi

# --- 2. Dependabot PRs open > 24h ---
AGING=$("$GH" pr list --repo "$REPO" --state open --author "dependabot[bot]" --limit 50 \
  --json number,title,createdAt \
  | jq '[.[] | select((.createdAt | fromdateiso8601) < (now - 86400))]')
if [ "$(echo "$AGING" | jq 'length')" -gt 0 ]; then
  echo "### Dependabot PRs open more than 24h"
  echo "$AGING" | jq -r '.[] | "- #\(.number) \(.title) (opened \(.createdAt))"'
  echo ""
fi

# --- 3. Production smoke check red on develop ---
SMOKE=$("$GH" run list --repo "$REPO" --workflow production-smoke-check.yml \
  --branch develop --limit 1 --json conclusion,url,createdAt)
if [ "$(echo "$SMOKE" | jq -r '.[0].conclusion // "none"')" = "failure" ]; then
  echo "### Production Smoke Check failing on develop"
  echo "- Latest run: $(echo "$SMOKE" | jq -r '.[0].url') ($(echo "$SMOKE" | jq -r '.[0].createdAt'))"
  echo ""
fi

# --- 4. Rails CI red on develop ---
CI=$("$GH" run list --repo "$REPO" --workflow main.yml \
  --branch develop --limit 1 --json conclusion,url,createdAt)
if [ "$(echo "$CI" | jq -r '.[0].conclusion // "none"')" = "failure" ]; then
  echo "### Rails CI (main.yml) failing on develop"
  echo "- Latest run: $(echo "$CI" | jq -r '.[0].url') ($(echo "$CI" | jq -r '.[0].createdAt'))"
  echo ""
fi
