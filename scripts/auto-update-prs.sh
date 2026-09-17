#!/usr/bin/env bash
# Auto-update PRs: refresh open same-repository PRs that are BEHIND develop and
# restore their pre-existing auto-merge requests.
#
# GitHub recomputes mergeStateStatus asynchronously after a base-branch push
# (issue #2996), so a queued auto-merge PR can read stale on the first
# snapshot. Auto-merge-queued PRs that do not read BEHIND are re-checked
# against fresh per-PR state with a bounded retry before being skipped.
#
# Required env:
#   REPO    - owner/name of the repository
#   GH_TOKEN
# Optional env (bounds; tests override):
#   GH_BIN                              - gh-compatible CLI (default: gh)
#   AUTO_UPDATE_RECHECK_ATTEMPTS        - fresh-state rechecks per queued PR (default: 4)
#   AUTO_UPDATE_RECHECK_DELAY_SECONDS   - delay between rechecks (default: 15)
#   AUTO_UPDATE_HEAD_WAIT_ATTEMPTS      - head-SHA polls after update-branch (default: 12)
#   AUTO_UPDATE_HEAD_WAIT_DELAY_SECONDS - delay between head-SHA polls (default: 5)
set -euo pipefail

GH="${GH_BIN:-gh}"
REPO="${REPO:?set REPO to owner/name}"
RECHECK_ATTEMPTS="${AUTO_UPDATE_RECHECK_ATTEMPTS:-4}"
RECHECK_DELAY="${AUTO_UPDATE_RECHECK_DELAY_SECONDS:-15}"
HEAD_WAIT_ATTEMPTS="${AUTO_UPDATE_HEAD_WAIT_ATTEMPTS:-12}"
HEAD_WAIT_DELAY="${AUTO_UPDATE_HEAD_WAIT_DELAY_SECONDS:-5}"

echo "Listing PRs targeting develop that may be behind..."
# Capture first so a gh/jq failure aborts the run instead of reading as an
# empty list (process substitution would swallow the producer's exit status).
PRS_TSV=$("$GH" pr list \
  --repo "$REPO" --base develop --state open --limit 50 \
  --json number,isCrossRepository,headRefName,headRefOid,mergeStateStatus,autoMergeRequest \
  | jq -r '.[] |
    select(.isCrossRepository == false) |
    [.number, .headRefName, .headRefOid, .mergeStateStatus, (.autoMergeRequest != null)] |
    @tsv')
PRS=()
while IFS= read -r line; do
  PRS+=("$line")
done <<< "$PRS_TSV"

CANDIDATES=()
QUEUED=()
if [ ${#PRS[@]} -gt 0 ]; then
  for PR_DATA in "${PRS[@]}"; do
    IFS=$'\t' read -r _ _ _ STATE HAS_AUTO_MERGE <<< "$PR_DATA"
    if [ "$STATE" = "BEHIND" ]; then
      CANDIDATES+=("$PR_DATA")
    elif [ "$HAS_AUTO_MERGE" = "true" ]; then
      QUEUED+=("$PR_DATA")
    fi
  done
fi

# Fresh-state recheck for queued auto-merge PRs whose snapshot state may be
# stale. BEHIND promotes the PR to a candidate; another definitive state means
# it resolved itself; still-UNKNOWN at the bound is reported as a failure
# below so exhaustion can never look like silent success.
UNRESOLVED=0
if [ ${#QUEUED[@]} -gt 0 ]; then
  for PR_DATA in "${QUEUED[@]}"; do
    IFS=$'\t' read -r PR HEAD_BRANCH HEAD_SHA STATE HAS_AUTO_MERGE <<< "$PR_DATA"
    FRESH_STATE="$STATE"
    FRESH_SHA="$HEAD_SHA"
    for ((attempt = 1; attempt <= RECHECK_ATTEMPTS; attempt++)); do
      sleep "$RECHECK_DELAY"
      read -r FRESH_STATE FRESH_SHA < <("$GH" pr view "$PR" --repo "$REPO" \
        --json mergeStateStatus,headRefOid \
        | jq -r '[.mergeStateStatus, .headRefOid] | @tsv')
      if [ "$FRESH_STATE" = "BEHIND" ]; then
        echo "PR #${PR} reported BEHIND on fresh-state recheck ${attempt}/${RECHECK_ATTEMPTS}"
        CANDIDATES+=("$(printf '%s\t%s\t%s\t%s\t%s' "$PR" "$HEAD_BRANCH" "$FRESH_SHA" "$FRESH_STATE" "$HAS_AUTO_MERGE")")
        break
      fi
      if [ "$FRESH_STATE" != "UNKNOWN" ]; then
        echo "PR #${PR} fresh state is ${FRESH_STATE}; no update needed."
        break
      fi
      echo "PR #${PR} merge state still UNKNOWN (recheck ${attempt}/${RECHECK_ATTEMPTS})"
    done
    if [ "$FRESH_STATE" = "UNKNOWN" ]; then
      echo "::error::PR #${PR} never reached a definitive merge state after ${RECHECK_ATTEMPTS} rechecks"
      UNRESOLVED=$((UNRESOLVED + 1))
    fi
  done
fi

if [ ${#CANDIDATES[@]} -gt 0 ]; then
  for PR_DATA in "${CANDIDATES[@]}"; do
    IFS=$'\t' read -r PR HEAD_BRANCH HEAD_SHA _ RESTORE_AUTO_MERGE <<< "$PR_DATA"
    echo "Updating branch on PR #${PR}"

    "$GH" api \
      -X PUT \
      "repos/${REPO}/pulls/${PR}/update-branch" \
      -f expected_head_sha="$HEAD_SHA"

    UPDATED_HEAD_SHA="$HEAD_SHA"
    for ((wait_attempt = 1; wait_attempt <= HEAD_WAIT_ATTEMPTS; wait_attempt++)); do
      sleep "$HEAD_WAIT_DELAY"
      UPDATED_HEAD_SHA=$("$GH" pr view "$PR" --repo "$REPO" --json headRefOid | jq -r '.headRefOid')
      if [[ "$UPDATED_HEAD_SHA" != "$HEAD_SHA" ]]; then
        break
      fi
    done

    if [[ "$UPDATED_HEAD_SHA" == "$HEAD_SHA" ]]; then
      echo "PR #${PR} did not receive an updated head commit within ${HEAD_WAIT_ATTEMPTS} polls."
      exit 1
    fi

    if [[ "$RESTORE_AUTO_MERGE" == "true" ]]; then
      echo "Restoring the existing auto-merge request on PR #${PR}"
      "$GH" pr merge --auto --squash "$PR" --repo "$REPO"
    fi

    echo "Triggering CI workflow for PR #${PR} (branch: ${HEAD_BRANCH})"
    "$GH" workflow run main.yml \
      --repo "$REPO" \
      --ref "${HEAD_BRANCH}" \
      --field triggered_by="auto-update-prs" \
      --field pr_number="${PR}"
  done
fi

if [ "$UNRESOLVED" -gt 0 ]; then
  echo "::error::${UNRESOLVED} queued auto-merge PR(s) never reached a definitive merge state"
  exit 1
fi

if [ ${#CANDIDATES[@]} -eq 0 ]; then
  echo "No open PRs behind develop."
fi
echo "Done."
