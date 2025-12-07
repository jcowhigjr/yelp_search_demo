#!/bin/bash
# Check PR status after push - CI results and @claude review
# Usage: ./scripts/check-pr-status.sh [pr_number]

set -euo pipefail

# Get PR number from argument or detect from current branch
if [ $# -eq 1 ]; then
  PR_NUMBER="$1"
else
  # Try to get PR number from current branch
  BRANCH=$(git branch --show-current)
  PR_NUMBER=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")
  
  if [ -z "$PR_NUMBER" ]; then
    echo "❌ No PR found for current branch: $BRANCH"
    echo "   Usage: $0 [pr_number]"
    exit 1
  fi
fi

echo "🔍 Checking status for PR #$PR_NUMBER"
echo ""

# Get PR details
PR_DATA=$(gh pr view "$PR_NUMBER" --json title,state,isDraft,statusCheckRollup,reviews,comments)

TITLE=$(echo "$PR_DATA" | jq -r '.title')
STATE=$(echo "$PR_DATA" | jq -r '.state')
IS_DRAFT=$(echo "$PR_DATA" | jq -r '.isDraft')

echo "📋 PR #$PR_NUMBER: $TITLE"
echo "   State: $STATE (Draft: $IS_DRAFT)"
echo ""

# Check CI status
echo "🤖 CI Status:"
STATUS_CHECKS=$(echo "$PR_DATA" | jq -r '.statusCheckRollup[]? | "\(.name): \(.conclusion // .status)"')

if [ -z "$STATUS_CHECKS" ]; then
  echo "   ⏳ No CI checks have started yet"
  echo "   💡 CI typically starts within 1-2 minutes of push"
else
  echo "$STATUS_CHECKS" | while IFS= read -r line; do
    if echo "$line" | grep -q "SUCCESS\|COMPLETED"; then
      echo "   ✅ $line"
    elif echo "$line" | grep -q "FAILURE\|FAILED"; then
      echo "   ❌ $line"
    elif echo "$line" | grep -q "PENDING\|IN_PROGRESS\|QUEUED"; then
      echo "   ⏳ $line"
    else
      echo "   ℹ️  $line"
    fi
  done
fi

echo ""

# Check for @claude review
echo "🤖 @claude Review:"
CLAUDE_COMMENTS=$(echo "$PR_DATA" | jq -r '.comments[]? | select(.author.login == "github-actions" and (.body | contains("Claude") or contains("AI Code Review"))) | .body' | head -n 1)

if [ -z "$CLAUDE_COMMENTS" ]; then
  echo "   ⏳ No @claude review yet"
  echo "   💡 @claude review typically completes within 3-5 minutes"
  echo "   💡 Comment '@claude' to request review if needed"
else
  echo "   ✅ @claude has reviewed this PR"
  echo ""
  echo "   Review summary:"
  echo "$CLAUDE_COMMENTS" | head -n 10 | sed 's/^/   /'
  if [ $(echo "$CLAUDE_COMMENTS" | wc -l) -gt 10 ]; then
    echo "   ... (truncated, see PR for full review)"
  fi
fi

echo ""

# Check for human reviews
echo "👤 Human Reviews:"
REVIEWS=$(echo "$PR_DATA" | jq -r '.reviews[]? | "\(.author.login): \(.state)"')

if [ -z "$REVIEWS" ]; then
  echo "   ⏳ No human reviews yet"
else
  echo "$REVIEWS" | while IFS= read -r line; do
    if echo "$line" | grep -q "APPROVED"; then
      echo "   ✅ $line"
    elif echo "$line" | grep -q "CHANGES_REQUESTED"; then
      echo "   ❌ $line"
    elif echo "$line" | grep -q "COMMENTED"; then
      echo "   💬 $line"
    else
      echo "   ℹ️  $line"
    fi
  done
fi

echo ""

# Check for preview deployment
echo ""
echo "🚀 Preview Deployment:"
DEPLOYMENT_URL=$(gh api graphql -f query="
query {
  repository(owner: \"jcowhigjr\", name: \"yelp_search_demo\") {
    pullRequest(number: $PR_NUMBER) {
      commits(last: 1) {
        nodes {
          commit {
            deployments(first: 5) {
              nodes {
                environment
                latestStatus {
                  environmentUrl
                  state
                }
              }
            }
          }
        }
      }
    }
  }
}" 2>/dev/null | jq -r '.data.repository.pullRequest.commits.nodes[0].commit.deployments.nodes[]? | select(.latestStatus.state == "SUCCESS") | .latestStatus.environmentUrl' | head -1)

if [ -n "$DEPLOYMENT_URL" ]; then
  echo "   ✅ Preview app deployed: $DEPLOYMENT_URL"
  echo "   💡 Use browser_preview tool to inspect UI changes"
else
  echo "   ⏳ No preview deployment yet (takes ~3 minutes from push)"
fi

# Summary
ALL_CHECKS_PASSED=$(echo "$PR_DATA" | jq -r '.statusCheckRollup[]? | .conclusion' | grep -v "SUCCESS" | wc -l | tr -d ' ')
HAS_CHANGES_REQUESTED=$(echo "$PR_DATA" | jq -r '.reviews[]? | .state' | grep -q "CHANGES_REQUESTED" && echo "yes" || echo "no")

echo ""
if [ "$ALL_CHECKS_PASSED" = "0" ] && [ "$HAS_CHANGES_REQUESTED" = "no" ] && [ -n "$STATUS_CHECKS" ]; then
  echo "✅ PR looks good! All checks passed, no changes requested."
  echo "   Ready for merge when approved."
elif [ -z "$STATUS_CHECKS" ]; then
  echo "⏳ Still waiting for CI checks to start..."
  echo "   💡 Check back in 2-3 minutes"
else
  echo "⚠️  PR needs attention:"
  if [ "$ALL_CHECKS_PASSED" != "0" ]; then
    echo "   - Some CI checks failed or are pending"
  fi
  if [ "$HAS_CHANGES_REQUESTED" = "yes" ]; then
    echo "   - Changes requested in reviews"
  fi
fi

echo ""
echo "🔗 View PR: $(gh pr view "$PR_NUMBER" --json url --jq '.url')"
