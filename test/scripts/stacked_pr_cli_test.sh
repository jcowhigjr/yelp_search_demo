#!/usr/bin/env bash
set -euo pipefail

# Simple CLI tests for scripts/stacked-pr.sh using an isolated git repo.

fail() {
  echo "❌ $*" >&2
  exit 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local msg="${3:-}"
  if [[ "$expected" != "$actual" ]]; then
    if [[ -n "$msg" ]]; then
      fail "Expected '$expected', got '$actual' ($msg)"
    else
      fail "Expected '$expected', got '$actual'"
    fi
  fi
}

assert_contains() {
  local needle="$1"
  local haystack="$2"
  echo "$haystack" | grep -q "$needle" || fail "Expected output to contain '$needle'"
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

cd "$TMPDIR"

echo "📁 Using temp repo at $TMPDIR"

git init -q

git config user.name "Stacked PR Test"
git config user.email "stacked-pr-test@example.com"

echo "# root" > README.md
git add README.md
git commit -q -m "Initial commit on default branch"
# Ensure the default branch is named develop for reproducible tests
git branch -m develop

cp "$REPO_ROOT/scripts/stacked-pr.sh" ./stacked-pr.sh
chmod +x ./stacked-pr.sh

# 1) create should create and checkout a new branch and record parent
STACKED_PR_SKIP_REMOTE=1 ./stacked-pr.sh create feature/cli-test
current_branch="$(git branch --show-current)"
assert_eq "feature/cli-test" "$current_branch" "create should checkout new branch"

# Config key uses a sanitized version of the branch name with slashes/underscores -> hyphens
parent_cfg="$(git config stackparent.feature-cli-test || true)"
assert_eq "develop" "$parent_cfg" "parent should be recorded as develop"

# 2) sync should rebase on parent and keep us on the same branch
STACKED_PR_SKIP_REMOTE=1 ./stacked-pr.sh sync feature/cli-test
current_branch_after_sync="$(git branch --show-current)"
assert_eq "feature/cli-test" "$current_branch_after_sync" "sync should keep us on feature branch"

# 3) show should print a chain including the feature branch and its parent
show_output="$(STACKED_PR_SKIP_REMOTE=1 ./stacked-pr.sh show feature/cli-test)"
assert_contains "feature/cli-test" "$show_output"
assert_contains "develop" "$show_output"

# 4) legacy stack.parent.<branch> namespace should still be respected when syncing
# Simulate an older repo that only has the legacy key for a different branch

git checkout -q develop
git checkout -q -b feature/legacy

git config stack.parent.feature-legacy develop

STACKED_PR_SKIP_REMOTE=1 ./stacked-pr.sh sync feature/legacy
legacy_parent_cfg="$(git config stackparent.feature-legacy || true)"
# We don't require writing back to the legacy key, but lookup_parent must at least
# see develop as the parent and allow sync to succeed without errors.
assert_eq "" "$legacy_parent_cfg" "sync should not be forced to write new namespace for legacy key"

echo "✅ stacked-pr.sh CLI smoke tests passed"
