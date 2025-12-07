#!/bin/bash
# scripts/ci-flake-check.sh
#
# Goal:
# - When there is an open PR for this branch AND the latest CI run for that PR failed,
#   help distinguish real breakages from flaky (usually system) tests.
# - Behavior:
#   * If CI failure is a system-test job:
#       - Reproduce locally with the matching system-test command.
#       - If local run FAILS: block push (exit 1) and show guidance.
#       - If local run PASSES: treat as likely flake:
#           - Re-run the failed CI job once.
#           - Open a "flaky system test" issue with details.
#           - Allow push (exit 0).
#   * For other failures or missing data: print info and exit 0 (non-blocking).
#
# NOTE: This script intentionally focuses on flaky system tests first. It is
# a complement to existing pre-push hooks (rails-tests, rails-system-tests).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=github-auth-check.sh
. "${SCRIPT_DIR}/github-auth-check.sh"

log_info()  { echo "[ci-flake-check] $*"; }
log_warn()  { echo "[ci-flake-check][WARN] $*"; }
log_error() { echo "[ci-flake-check][ERROR] $*" >&2; }

# 1) Ensure we can talk to GitHub (will exit non-zero on failure).
ensure_github_auth "human"

# 2) Detect if this branch has an open PR
if ! gh pr view &>/dev/null; then
  log_info "No open PR for this branch; skipping CI flake check."
  exit 0
fi

PR_JSON=$(gh pr view --json number,headRefName,headRefOid,url 2>/dev/null || echo "{}")
PR_NUMBER=$(echo "$PR_JSON" | jq -r '.number // empty')
HEAD_SHA=$(echo "$PR_JSON"   | jq -r '.headRefOid // empty')
PR_URL=$(echo "$PR_JSON"     | jq -r '.url // empty')

if [[ -z "$PR_NUMBER" || -z "$HEAD_SHA" ]]; then
  log_warn "Could not determine PR number or head SHA; skipping CI flake check."
  exit 0
fi

log_info "Checking latest CI failures for PR #$PR_NUMBER ($PR_URL) at $HEAD_SHA..."

# 3) Find most recent failed workflow run for this head SHA
RUNS_JSON=$(gh run list --json databaseId,headSha,conclusion --limit 20 2>/dev/null || echo "[]")

FAILED_RUN_ID=$(echo "$RUNS_JSON" | jq -r --arg sha "$HEAD_SHA" '
  [.[]
   | select(.headSha == $sha and .conclusion == "failure")][0].databaseId // ""
')

if [[ -z "$FAILED_RUN_ID" || "$FAILED_RUN_ID" == "null" ]]; then
  log_info "No failing CI runs found for this PR head SHA; nothing to reconcile."
  exit 0
fi

# Derive run URL from repo slug and run ID to avoid relying on extra JSON fields.
REPO_SLUG=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || echo "")
if [[ -n "$REPO_SLUG" ]]; then
  RUN_URL="https://github.com/$REPO_SLUG/actions/runs/$FAILED_RUN_ID"
else
  RUN_URL="(GitHub run $FAILED_RUN_ID)"
fi

RUN_DETAILS=$(gh run view "$FAILED_RUN_ID" --json jobs 2>/dev/null || echo "{}")

log_info "Found failing workflow run $FAILED_RUN_ID -> $RUN_URL"

FAILED_JOBS=$(echo "$RUN_DETAILS" | jq '[.jobs[] | select(.conclusion == "failure")]')
FAILED_JOB_COUNT=$(echo "$FAILED_JOBS" | jq 'length')

if [[ "$FAILED_JOB_COUNT" -eq 0 ]]; then
  log_info "Run is marked as failure but no failed jobs were found; skipping."
  exit 0
fi

# For now, only handle flaky *system-test* jobs in either the classic `test` or `test-next` workflow jobs.
TARGET_JOB=$(echo "$FAILED_JOBS" | jq -r '
  .[] | select(.name == "test" or .name == "test-next") | .name
' | head -n1)

if [[ -z "$TARGET_JOB" || "$TARGET_JOB" == "null" ]]; then
  log_info "CI failure is not in test/test-next jobs; skipping flake automation."
  exit 0
fi

# Within that job, confirm the failing step is a system-test step.
FAILED_STEP_NAME=$(echo "$RUN_DETAILS" | jq -r --arg job "$TARGET_JOB" '
  .jobs[]
  | select(.name == $job)
  | .steps[]
  | select(.conclusion == "failure")
  | .name
' | head -n1)

if [[ -z "$FAILED_STEP_NAME" || "$FAILED_STEP_NAME" == "null" ]]; then
  log_info "No failed steps found within job '$TARGET_JOB'; skipping."
  exit 0
fi

case "$FAILED_STEP_NAME" in
  *system-test*|*system-tests*)
    ;;
  *)
    log_info "Failed step '$FAILED_STEP_NAME' is not a system-test step; skipping flake automation."
    exit 0
    ;;
esac

log_info "Detected failing system-test step '$FAILED_STEP_NAME' in job '$TARGET_JOB'. Attempting local reproduction..."

# 4) Map CI job to local system-test command
LOCAL_CMD=""
if [[ "$TARGET_JOB" == "test" ]]; then
  LOCAL_CMD="mise exec -- CI=true RAILS_ENV=test HEADLESS=true CUPRITE=true APP_HOST='localhost' CUPRITE_JS_ERRORS=false bin/rails test:system"
elif [[ "$TARGET_JOB" == "test-next" ]]; then
  LOCAL_CMD="mise exec -- CI=true RAILS_ENV=test HEADLESS=true CUPRITE=true APP_HOST='localhost' CUPRITE_JS_ERRORS=false next rails test:system"
fi

if [[ -z "$LOCAL_CMD" ]]; then
  log_warn "Could not determine local command for job '$TARGET_JOB'; skipping."
  exit 0
fi

log_info "Running local reproduction command:\n  $LOCAL_CMD"

# 5) Run local system tests. If they fail, block push.
if ! eval "$LOCAL_CMD"; then
  log_error "Local system tests FAILED while CI also failing. Treating this as a real failure and blocking push."
  log_error "Please fix the system tests locally before pushing."
  echo "  - PR: $PR_URL"
  echo "  - CI run: $RUN_URL"
  exit 1
fi

log_info "Local system tests PASSED for the same surface. Treating CI failure as likely flaky."

# 6) Re-run failed CI jobs once.
log_info "Re-running failed jobs for workflow run $FAILED_RUN_ID (one attempt)..."
if ! gh run rerun "$FAILED_RUN_ID" --failed 2>/dev/null; then
  log_warn "Failed to request CI rerun via gh; you may need to rerun manually from the GitHub UI."
else
  log_info "Requested CI rerun for failed jobs. See: $RUN_URL"
fi

# 7) Create (or attempt to create) a flaky test issue.
ISSUE_TITLE="Flaky system test in CI: $TARGET_JOB ($FAILED_STEP_NAME) on PR #$PR_NUMBER"
ISSUE_BODY=$(cat <<EOF
CI detected a failing system test job that passed when reproduced locally.

- PR: $PR_URL
- Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
- Workflow run: $RUN_URL
- Job: $TARGET_JOB
- Failing step: $FAILED_STEP_NAME

Local reproduction command:

\`\`\`
$LOCAL_CMD
\`\`\`

Local run **passed**, but CI previously failed. This suggests a flaky or timing-sensitive system test.

Please investigate the underlying test and either deflake or quarantine as appropriate.
EOF
)

log_info "Creating flaky-test issue to track this behavior..."
if ! gh issue create \
  --title "$ISSUE_TITLE" \
  --body "$ISSUE_BODY" \
  --label "flaky-test" 2>/dev/null; then
  log_warn "Failed to create flaky-test issue via gh; you may need to file it manually."
else
  log_info "Flaky-test issue created successfully."
fi

log_info "CI flake check completed: local tests passed, CI rerun requested, flaky issue recorded. Allowing push."
exit 0
