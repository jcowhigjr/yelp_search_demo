#!/bin/bash
# scripts/pr-completion-check.sh
#
# Validate PR completion state by checking all requirements for merge
# Usage: ./scripts/pr-completion-check.sh [--json]
#
# Checks:
#   - Review threads resolved
#   - CI checks passing
#   - Branch up-to-date
#   - Merge conflicts
#   - Approval requirements
#
# Exit codes:
#   0 - PR is ready to merge
#   1 - PR has blockers
#   2 - Error (not on a PR branch, etc.)

set -e

# Parse arguments
OUTPUT_JSON=false
if [[ "$1" == "--json" ]]; then
  OUTPUT_JSON=true
fi

# Check if we're on a branch with a PR
if ! gh pr view &>/dev/null; then
  if [[ "$OUTPUT_JSON" == "true" ]]; then
    echo '{"error": "Not on a branch with an open PR", "ready_to_merge": false}'
  else
    echo "❌ Not on a branch with an open PR"
  fi
  exit 2
fi

# Get PR info
PR_NUMBER=$(gh pr view --json number --jq '.number')
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')

if [[ "$OUTPUT_JSON" == "false" ]]; then
  echo "🔍 Checking PR #$PR_NUMBER completion status..."
  echo ""
fi

# Initialize status tracking
STATUS_REVIEWS=false
STATUS_CI=false
STATUS_UP_TO_DATE=false
STATUS_MERGEABLE=false
STATUS_APPROVALS=false

BLOCKERS=()

# 1. Check review threads
if [[ "$OUTPUT_JSON" == "false" ]]; then
  echo "📋 Phase 0: Checking review threads..."
fi

REVIEW_DATA=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
          }
        }
      }
    }
  }
' -f owner="$REPO_OWNER" -f repo="$REPO_NAME" -F number="$PR_NUMBER")

UNRESOLVED_REVIEWS=$(echo "$REVIEW_DATA" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)] | length')

if [[ "$UNRESOLVED_REVIEWS" -eq 0 ]]; then
  STATUS_REVIEWS=true
  if [[ "$OUTPUT_JSON" == "false" ]]; then
    echo "   ✅ All review threads resolved"
  fi
else
  BLOCKERS+=("$UNRESOLVED_REVIEWS unresolved review thread(s)")
  if [[ "$OUTPUT_JSON" == "false" ]]; then
    echo "   ❌ $UNRESOLVED_REVIEWS unresolved review thread(s)"
  fi
fi

# 2. Check CI status
if [[ "$OUTPUT_JSON" == "false" ]]; then
  echo "🔧 Phase 1-2: Checking CI status..."
fi

CI_STATUS=$(gh pr checks --json name,state,conclusion 2>/dev/null || echo "[]")
FAILING_CHECKS=$(echo "$CI_STATUS" | jq '[.[] | select(.state == "FAILURE" or .conclusion == "FAILURE")] | length')
PENDING_CHECKS=$(echo "$CI_STATUS" | jq '[.[] | select(.state == "PENDING" or .state == "IN_PROGRESS")] | length')

if [[ "$FAILING_CHECKS" -gt 0 ]]; then
  BLOCKERS+=("$FAILING_CHECKS failing CI check(s)")
  if [[ "$OUTPUT_JSON" == "false" ]]; then
    echo "   ❌ $FAILING_CHECKS failing CI check(s)"
    echo "$CI_STATUS" | jq -r '.[] | select(.state == "FAILURE" or .conclusion == "FAILURE") | "      - \(.name): \(.conclusion // .state)"'
  fi
elif [[ "$PENDING_CHECKS" -gt 0 ]]; then
  BLOCKERS+=("$PENDING_CHECKS pending CI check(s)")
  if [[ "$OUTPUT_JSON" == "false" ]]; then
    echo "   ⏳ $PENDING_CHECKS pending CI check(s)"
  fi
else
  STATUS_CI=true
  if [[ "$OUTPUT_JSON" == "false" ]]; then
    echo "   ✅ All CI checks passing"
  fi
fi

# 3. Check if branch is up-to-date
if [[ "$OUTPUT_JSON" == "false" ]]; then
  echo "🔄 Phase 4: Checking branch status..."
fi

git fetch origin develop --quiet 2>/dev/null || true
BEHIND_COUNT=$(git rev-list --count HEAD..origin/develop 2>/dev/null || echo "0")

if [[ "$BEHIND_COUNT" -eq 0 ]]; then
  STATUS_UP_TO_DATE=true
  if [[ "$OUTPUT_JSON" == "false" ]]; then
    echo "   ✅ Branch is up-to-date with develop"
  fi
else
  BLOCKERS+=("Branch is $BEHIND_COUNT commit(s) behind develop")
  if [[ "$OUTPUT_JSON" == "false" ]]; then
    echo "   ❌ Branch is $BEHIND_COUNT commit(s) behind develop"
  fi
fi

# 4. Check merge status
if [[ "$OUTPUT_JSON" == "false" ]]; then
  echo "🔀 Phase 5: Checking merge status..."
fi

MERGE_DATA=$(gh pr view --json mergeable,mergeStateStatus,reviewDecision)
MERGEABLE=$(echo "$MERGE_DATA" | jq -r '.mergeable')
MERGE_STATE=$(echo "$MERGE_DATA" | jq -r '.mergeStateStatus')
REVIEW_DECISION=$(echo "$MERGE_DATA" | jq -r '.reviewDecision')

if [[ "$MERGEABLE" == "MERGEABLE" ]]; then
  STATUS_MERGEABLE=true
  if [[ "$OUTPUT_JSON" == "false" ]]; then
    echo "   ✅ No merge conflicts"
  fi
else
  BLOCKERS+=("Merge conflicts detected")
  if [[ "$OUTPUT_JSON" == "false" ]]; then
    echo "   ❌ Merge conflicts detected"
  fi
fi

# 5. Check approval requirements
if [[ "$OUTPUT_JSON" == "false" ]]; then
  echo "👥 Phase 3: Checking approval status..."
fi

case "$MERGE_STATE" in
  "BLOCKED")
    if [[ "$REVIEW_DECISION" == "APPROVED" ]]; then
      STATUS_APPROVALS=true
      if [[ "$OUTPUT_JSON" == "false" ]]; then
        echo "   ✅ Approvals met (merge blocked by other reason)"
      fi
    elif [[ "$REVIEW_DECISION" == "CHANGES_REQUESTED" ]]; then
      BLOCKERS+=("Changes requested by reviewer")
      if [[ "$OUTPUT_JSON" == "false" ]]; then
        echo "   ❌ Changes requested by reviewer"
      fi
    elif [[ "$REVIEW_DECISION" == "REVIEW_REQUIRED" ]]; then
      BLOCKERS+=("Review required before merge")
      if [[ "$OUTPUT_JSON" == "false" ]]; then
        echo "   ❌ Review required before merge"
      fi
    else
      BLOCKERS+=("Approval required (self-approval blocked)")
      if [[ "$OUTPUT_JSON" == "false" ]]; then
        echo "   ⚠️  Approval required (self-approval blocked)"
        echo "      Consider admin merge if appropriate"
      fi
    fi
    ;;
  "CLEAN")
    STATUS_APPROVALS=true
    if [[ "$OUTPUT_JSON" == "false" ]]; then
      echo "   ✅ Ready to merge"
    fi
    ;;
  *)
    if [[ "$OUTPUT_JSON" == "false" ]]; then
      echo "   ℹ️  Merge state: $MERGE_STATE"
    fi
    ;;
esac

# Summary
if [[ "$OUTPUT_JSON" == "true" ]]; then
  # JSON output
  BLOCKERS_JSON=$(printf '%s\n' "${BLOCKERS[@]}" | jq -R . | jq -s .)
  cat <<EOF
{
  "pr_number": $PR_NUMBER,
  "ready_to_merge": $([ ${#BLOCKERS[@]} -eq 0 ] && echo "true" || echo "false"),
  "status": {
    "reviews_resolved": ${STATUS_REVIEWS},
    "ci_passing": ${STATUS_CI},
    "branch_up_to_date": ${STATUS_UP_TO_DATE},
    "no_conflicts": ${STATUS_MERGEABLE},
    "approvals_met": ${STATUS_APPROVALS}
  },
  "blockers": $BLOCKERS_JSON,
  "merge_state": "$MERGE_STATE",
  "review_decision": "$REVIEW_DECISION"
}
EOF
else
  # Human-readable summary
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Summary for PR #$PR_NUMBER"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  if [ ${#BLOCKERS[@]} -eq 0 ]; then
    echo "✅ PR is ready to merge!"
    echo ""
    echo "Next steps:"
    echo "  - Run: gh pr merge --auto --squash"
    echo "  - Or:  gh pr merge --admin --squash (if self-approval blocked)"
  else
    echo "❌ PR has ${#BLOCKERS[@]} blocker(s):"
    for blocker in "${BLOCKERS[@]}"; do
      echo "  • $blocker"
    done
    echo ""
    echo "Next steps:"
    if [[ "$UNRESOLVED_REVIEWS" -gt 0 ]]; then
      echo "  1. Check reviews: ./scripts/review-loop.sh"
      echo "  2. Address feedback and resolve threads"
    fi
    if [[ "$FAILING_CHECKS" -gt 0 ]]; then
      echo "  • Fix failing CI checks"
      echo "    - View logs: gh run view --log-failed"
      echo "    - Reproduce locally and fix"
    fi
    if [[ "$BEHIND_COUNT" -gt 0 ]]; then
      echo "  • Sync branch: ./scripts/sync-branch.sh develop"
    fi
  fi
fi

# Exit with appropriate code
if [ ${#BLOCKERS[@]} -eq 0 ]; then
  exit 0
else
  exit 1
fi
