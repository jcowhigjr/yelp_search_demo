# Review-First Autopilot Loop

Detailed protocol for AI agents to autonomously handle PR review feedback without user intervention.

## Core Principle

**Always check for reviews FIRST before any other action when working on a PR.**

This creates a continuous review-response loop that eliminates the need for users to prompt "address the feedback" or "continue."

## The Problem (PR #952 Experience)

In PR #952, the agent required 4 "continue" prompts because it:

1. ❌ Didn't check for reviews automatically
2. ❌ Didn't fix reviewer comments without being told
3. ❌ Didn't mark comments as resolved in GitHub
4. ❌ Didn't retry automatically after resolving

**Result**: User frustration and wasted time.

## The Solution: Autonomous Review Loop

```
┌──────────────────────────────────────────┐
│ Agent starts working on PR               │
└───────────────┬──────────────────────────┘
                ↓
┌───────────────────────────────────────────┐
│ CHECK FOR REVIEWS (GitHub GraphQL API)   │
│ Query: reviewThreads.nodes.isResolved     │
└───────────┬───────────────────────────────┘
            ↓
      Has unresolved threads?
            │
     ┌──────┴──────┐
     │             │
    YES            NO
     │             │
     ↓             ↓
┌─────────────────────────┐   ┌──────────────────┐
│ READ all comments       │   │ Continue to      │
│ - Inline (code)         │   │ other PR work    │
│ - General (PR-level)    │   │ (CI, merge, etc) │
└──────┬──────────────────┘   └──────────────────┘
       ↓
┌─────────────────────────┐
│ FIX each issue in code  │
│ - Make necessary changes│
│ - Ensure tests pass     │
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ COMMIT with message     │
│ "Fix review feedback:   │
│  - Issue 1              │
│  - Issue 2"             │
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ PUSH to remote          │
│ (pre-push hooks         │
│  validate automatically)│
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ REPLY to each comment   │
│ "✅ Fixed in commit XYZ"│
│ Document what changed   │
└──────┬──────────────────┘
       ↓
┌─────────────────────────┐
│ RESOLVE each thread     │
│ (GitHub GraphQL API)    │
└──────┬──────────────────┘
       ↓
    GOTO TOP (check again)
```

## Implementation Guide

### Step 1: Check for Reviews

Always start by querying for unresolved review threads.

```bash
#!/bin/bash
# Get current PR number
PR_NUMBER=$(gh pr view --json number --jq '.number')
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')

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
                id
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
UNRESOLVED_COUNT=$(echo "$REVIEW_DATA" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)] | length')

echo "Found $UNRESOLVED_COUNT unresolved review thread(s)"
```

### Step 2: Read and Understand Comments

Extract actionable feedback from each thread.

```bash
# Get details of unresolved threads
echo "$REVIEW_DATA" | jq -r '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | {
  thread_id: .id,
  outdated: .isOutdated,
  comments: [.comments.nodes[] | {
    author: .author.login,
    body: .body,
    file: .path,
    line: .line,
    start_line: .startLine,
    comment_id: .databaseId
  }]
}'
```

**Example output:**
```json
{
  "thread_id": "PRRT_kwDOAGYtD85fh47z",
  "outdated": false,
  "comments": [
    {
      "author": "chatgpt-codex-connector",
      "body": "**Ensure feature branches are created from develop**\n\nThe sync script returns to the original branch...",
      "file": "workflow-new-feature.sh",
      "line": 33,
      "start_line": 31,
      "comment_id": 2467547306
    }
  ]
}
```

###Step 3: Fix the Code

Address each comment by making the necessary changes.

**Key Principles:**
- Make targeted fixes that directly address the comment
- Don't introduce unrelated changes
- Ensure tests still pass
- Follow existing code patterns

**Example** (from PR #952):
```bash
# Comment said: "Ensure we checkout develop after sync"
# Fix: Add explicit git checkout develop after sync script runs

# Read the file
vim workflow-new-feature.sh

# Make the change (lines 19-21)
# Added:
#   echo "📍 Ensuring we're on develop..."
#   git checkout develop
```

### Step 4: Commit Changes

Create a commit that clearly documents what was fixed.

```bash
# Commit with reference to the review
git add workflow-new-feature.sh
git commit -m "Fix review feedback: checkout develop after sync

Addresses review comment from @chatgpt-codex-connector:
After git-sync.sh runs, it returns to the original branch.
Now explicitly checking out develop before creating new branch
to ensure branches are always based on latest develop.

Fixes comment: https://github.com/owner/repo/pull/952#discussion_r2467547306"
```

### Step 5: Push (Triggers Pre-Push Hooks)

```bash
git push
```

**What happens automatically:**
- Lefthook pre-push hooks run
- Tests execute (unit + system)
- Linters validate
- Security audits run
- If hooks pass → code is pushed
- Remote CI starts running

**Key Insight**: Don't wait for remote CI before resolving threads. Pre-push hooks already validated the code.

### Step 6: Reply to Each Comment

Document what you fixed and where.

```bash
# Reply to the review comment
COMMENT_ID=2467547306  # From Step 2

gh api -X POST "repos/$REPO_OWNER/$REPO_NAME/pulls/$PR_NUMBER/comments/$COMMENT_ID/replies" \
  -f body="✅ Fixed in commit $(git rev-parse --short HEAD)

Added explicit \`git checkout develop\` after sync script runs (line 20-21).

Now the workflow ensures new branches are always created from the latest develop, regardless of which branch the command was invoked from."
```

### Step 7: Resolve the Thread

Mark the thread as resolved using GraphQL.

```bash
# Resolve the thread
THREAD_ID="PRRT_kwDOAGYtD85fh47z"  # From Step 2

gh api graphql -f query="
  mutation {
    resolveReviewThread(input: {threadId: \"$THREAD_ID\"}) {
      thread {
        id
        isResolved
      }
    }
  }
"
```

**Expected response:**
```json
{
  "data": {
    "resolveReviewThread": {
      "thread": {
        "id": "PRRT_kwDOAGYtD85fh47z",
        "isResolved": true
      }
    }
  }
}
```

### Step 8: Loop Back

**Immediately** check for reviews again (Step 1).

Why? Because:
- Reviewers might have added new comments
- Other automated tools (like codex) might have added feedback
- You need to ensure ALL reviews are addressed before proceeding

```bash
# Don't stop here! Go back to Step 1
# Check if there are more unresolved threads
```

## Complete Script Example

Here's a full script that implements the review loop:

```bash
#!/bin/bash
# scripts/review-loop.sh
set -e

PR_NUMBER=$(gh pr view --json number --jq '.number')
REPO_OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO_NAME=$(gh repo view --json name --jq '.name')

echo "🔄 Checking for review threads on PR #$PR_NUMBER..."

# Query for unresolved threads
REVIEW_DATA=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 10) {
              nodes {
                databaseId
                body
                path
                line
                author { login }
              }
            }
          }
        }
      }
    }
  }
' -f owner="$REPO_OWNER" -f repo="$REPO_NAME" -F number="$PR_NUMBER")

# Count unresolved
UNRESOLVED=$(echo "$REVIEW_DATA" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)]')
COUNT=$(echo "$UNRESOLVED" | jq 'length')

if [ "$COUNT" -eq 0 ]; then
  echo "✅ No unresolved review threads"
  exit 0
fi

echo "⚠️  Found $COUNT unresolved review thread(s)"
echo ""
echo "Review comments to address:"
echo "$UNRESOLVED" | jq -r '.[] | "
Thread ID: \(.id)
Author: \(.comments.nodes[0].author.login)
File: \(.comments.nodes[0].path // "N/A")
Line: \(.comments.nodes[0].line // "N/A")
Comment: \(.comments.nodes[0].body)
---"'

exit 1  # Exit with error to indicate reviews need attention
```

## Integration with PR Completion Workflow

The review loop is **Phase 0** of the PR completion workflow and has the highest priority.

```
PR Completion Workflow Entry Point
         ↓
    Phase 0: Review Loop  ←──┐
         ↓                   │
    Has unresolved reviews?  │
         │                   │
    ┌────┴────┐              │
   YES       NO              │
    │         │              │
    ↓         ↓              │
  Fix &    Phase 1: Code ────┘ (may create new reviews)
  Resolve    Quality
    │         ↓
    └────→  Phase 2: CI/CD
              ↓
            Phase 3: Review Process (re-check)
              ↓
            Phase 4: Merge Prep
              ↓
            Phase 5: Merge
```

## Common Pitfalls to Avoid

### ❌ Waiting for User to Say "Address Feedback"

**Wrong:**
```
Agent: "I see there are review comments. Should I address them?"
User: "yes, address the feedback"  ← WASTED PROMPT
Agent: [fixes issues]
```

**Right:**
```
Agent: [checks for reviews]
Agent: [finds comments]
Agent: [fixes immediately]
Agent: [resolves threads]
Agent: [loops back to check again]
```

### ❌ Not Marking Threads Resolved

**Wrong:**
```
Agent: [fixes code]
Agent: [pushes]
Agent: "Fixed the review comments"  ← Thread still unresolved!
```

**Right:**
```
Agent: [fixes code]
Agent: [pushes]
Agent: [replies to comment]
Agent: [calls GraphQL API to resolve thread]  ← Explicit resolution
Agent: [verifies thread is resolved]
```

### ❌ Stopping After First Fix

**Wrong:**
```
Agent: [fixes one comment]
Agent: "Review feedback addressed, moving on..."  ← Other comments ignored!
```

**Right:**
```
Agent: [fixes ALL comments in single pass]
Agent: [pushes once]
Agent: [resolves ALL threads]
Agent: [checks for NEW comments]
Agent: [repeats if necessary]
```

### ❌ Waiting for Remote CI Before Resolving

**Wrong:**
```
Agent: [fixes review]
Agent: [pushes]
Agent: [waits for CI to pass]  ← UNNECESSARY DELAY
Agent: [then resolves thread]
```

**Right:**
```
Agent: [fixes review]
Agent: [pushes - pre-push hooks validate]
Agent: [immediately replies and resolves]  ← No waiting
Agent: [CI runs in parallel, doesn't block progress]
```

## GraphQL API Reference

### Query: Get Review Threads

```graphql
query GetReviewThreads($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first: 10) {
            nodes {
              id
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
```

### Mutation: Resolve Thread

```graphql
mutation ResolveThread($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread {
      id
      isResolved
    }
  }
}
```

### Mutation: Unresolve Thread (if needed)

```graphql
mutation UnresolveThread($threadId: ID!) {
  unresolveReviewThread(input: {threadId: $threadId}) {
    thread {
      id
      isResolved
    }
  }
}
```

## Success Metrics

Track these to measure review loop effectiveness:

- **Auto-fix rate**: % of review comments fixed without user prompt
- **Resolution latency**: Time from review posted to thread resolved
- **Multi-round efficiency**: # of reviews → # of user prompts (target: N → 0)
- **Thread resolution accuracy**: % of threads properly resolved in GitHub

## Related Documentation

- [PR Completion Workflow](./pr-completion-workflow.md) - Full PR lifecycle
- [Git Workflow](./git-workflow.md) - Branch management
- [WARP.md](../WARP.md) - Main agent instructions
