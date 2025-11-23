#!/bin/bash
# scripts/stacked-pr.sh
#
# Helper for managing stacked pull requests without extra dependencies.
# Commands:
#   create <branch> [--parent <parent>]
#   sync [branch]
#   show [branch]
#   queue
#
# Parent relationships are stored via git config using a normalized key so we
# avoid additional JSON files or jq parsing. New entries are written under the
# `stackparent.<branch>` namespace, but we remain backward compatible with older
# `stack.parent.<branch>` keys when reading existing stacks.

set -euo pipefail

STACK_PARENT_NAMESPACE="stackparent"

usage() {
  cat <<USAGE
Usage: $0 <command> [options]

Commands:
  create <branch> [--parent <parent>]  Create a stacked branch off current/parent
  sync [branch]                        Rebase branch on parent, push with --force-with-lease
  show [branch]                        Display parent chain for the branch (defaults to current)
  queue                                Run PR completion check and queue auto-merge
USAGE
}

require_clean_worktree() {
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "❌ Worktree is dirty. Please commit or stash changes first." >&2
    exit 1
  fi
}

assert_branch_exists() {
  local branch="$1"
  if ! git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "❌ Branch '$branch' does not exist locally." >&2
    exit 1
  fi
}

record_parent() {
  local branch="$1"
  local parent="$2"
  # Git config keys cannot contain '/', and underscores are not allowed in the
  # variable name portion, so normalize to hyphens while still using the real
  # branch name everywhere else.
  local key_branch="${branch//\//-}"
  key_branch="${key_branch//_/-}"
  git config "$STACK_PARENT_NAMESPACE.$key_branch" "$parent"
}

lookup_parent() {
  local branch="$1"
  local key_branch="${branch//\//-}"
  key_branch="${key_branch//_/-}"

  # Prefer the new namespace (stackparent.<branch>), but fall back to the
  # legacy stack.parent.<branch> key for existing stacks.
  local parent
  parent=$(git config --get "$STACK_PARENT_NAMESPACE.$key_branch" 2>/dev/null || true)
  if [[ -z "$parent" ]]; then
    parent=$(git config --get "stack.parent.$key_branch" 2>/dev/null || true)
  fi
  if [[ -z "$parent" ]]; then
    parent="develop"
  fi
  echo "$parent"
}

ensure_branch() {
  local wanted="$1"
  local current
  current=$(git branch --show-current)
  if [[ "$current" != "$wanted" ]]; then
    git checkout "$wanted" >/dev/null 2>&1
  fi
}

update_parent_from_remote() {
  local parent="$1"

  # In test contexts we may not have an origin remote configured; allow
  # tests to opt out of network calls with STACKED_PR_SKIP_REMOTE=1.
  if [[ "${STACKED_PR_SKIP_REMOTE:-0}" == "1" ]]; then
    ensure_branch "$parent"
    return
  fi

  git fetch origin "$parent" >/dev/null 2>&1 || true
  ensure_branch "$parent"
  git pull --ff-only origin "$parent"
}

create_branch() {
  local new_branch="$1"
  shift || true
  local parent=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --parent)
        parent="$2"
        shift 2
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        exit 1
        ;;
    esac
  done

  require_clean_worktree

  if git show-ref --verify --quiet "refs/heads/$new_branch"; then
    echo "❌ Branch '$new_branch' already exists." >&2
    exit 1
  fi

  if [[ -z "$parent" ]]; then
    parent=$(git branch --show-current)
  fi

  if [[ -z "$parent" ]]; then
    echo "❌ Unable to detect parent branch. Use --parent <branch>." >&2
    exit 1
  fi

  echo "📍 Parent branch: $parent"
  update_parent_from_remote "$parent"

  git checkout "$parent"
  git checkout -b "$new_branch"
  record_parent "$new_branch" "$parent"

  echo "✅ Created stacked branch '$new_branch' tracking parent '$parent'."
}

sync_branch() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    branch=$(git branch --show-current)
  fi

  if [[ -z "$branch" ]]; then
    echo "❌ No branch specified and unable to detect current branch." >&2
    exit 1
  fi

  assert_branch_exists "$branch"
  local parent
  parent=$(lookup_parent "$branch")

  echo "🔁 Syncing '$branch' with parent '$parent'..."
  update_parent_from_remote "$parent"
  ensure_branch "$branch"

  if git rebase "$parent"; then
    echo "✅ Rebased '$branch' onto '$parent'."
    if git rev-parse --verify --quiet "refs/remotes/origin/$branch"; then
      git push --force-with-lease origin "$branch"
      echo "📤 Pushed updated branch to origin."
    else
      echo "ℹ️  Branch not yet on origin. Push with: git push -u origin $branch"
    fi
  else
    echo "❌ Rebase failed. Resolve conflicts and run 'git rebase --continue'." >&2
    exit 1
  fi
}

show_branch() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    branch=$(git branch --show-current)
  fi
  if [[ -z "$branch" ]]; then
    echo "❌ No branch specified and none currently checked out." >&2
    exit 1
  fi

  echo "📚 Stack chain for '$branch':"
  local current="$branch"
  local depth=0
  while [[ -n "$current" ]]; do
    local parent
    parent=$(lookup_parent "$current")
    printf "  %s%s (parent: %s)\n" "$(printf '%*s' $depth '')" "$current" "$parent"
    if [[ "$parent" == "$current" ]]; then
      break
    fi
    if [[ "$parent" == "develop" || "$parent" == "main" ]]; then
      printf "  %s└─ %s (root)\n" "$(printf '%*s' $((depth + 2)) '')" "$parent"
      break
    fi
    current="$parent"
    depth=$((depth + 2))
    if [[ $depth -gt 40 ]]; then
      echo "  ... (stopped to prevent infinite loop)"
      break
    fi
  done
}

queue_branch() {
  if [[ ! -x ./scripts/pr-completion-check.sh ]]; then
    echo "❌ scripts/pr-completion-check.sh missing or not executable." >&2
    exit 1
  fi

  echo "🔍 Verifying PR readiness and queueing auto-merge (squash)..."
  ./scripts/pr-completion-check.sh --auto-merge
}

command=${1:-}
if [[ -z "$command" ]]; then
  usage
  exit 1
fi
shift || true

case "$command" in
  create)
    if [[ $# -lt 1 ]]; then
      echo "❌ Missing branch name for create." >&2
      usage
      exit 1
    fi
    create_branch "$1" "${@:2}"
    ;;
  sync)
    sync_branch "${1:-}"
    ;;
  show)
    show_branch "${1:-}"
    ;;
  queue)
    queue_branch
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo "Unknown command: $command" >&2
    usage
    exit 1
    ;;
esac
