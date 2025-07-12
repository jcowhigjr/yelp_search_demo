#!/bin/bash

# PR monitoring script for automated review and merge workflow
PR_NUMBER=810
OWNER=jcowhigjr
REPO=yelp_search_demo

echo "Monitoring PR #${PR_NUMBER} for review and merge automation..."
echo "$(date): Starting PR monitoring loop"

# Function to check PR status via GitHub CLI
check_pr_status() {
    echo "$(date): Checking PR status..."
    
    # Check if gh CLI is available
    if command -v gh &> /dev/null; then
        echo "$(date): Using GitHub CLI to check PR status"
        gh pr view ${PR_NUMBER} --repo ${OWNER}/${REPO} --json state,mergeable,mergeStateStatus,reviewDecision
    else
        echo "$(date): GitHub CLI not available, using basic curl"
        curl -s -H "Accept: application/vnd.github.v3+json" \
             "https://api.github.com/repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}" | \
             jq '{state: .state, mergeable: .mergeable, mergeable_state: .mergeable_state}'
    fi
}

# Function to enable auto-merge
enable_auto_merge() {
    echo "$(date): Attempting to enable auto-merge..."
    if command -v gh &> /dev/null; then
        gh pr merge ${PR_NUMBER} --repo ${OWNER}/${REPO} --auto --squash
        return $?
    else
        echo "$(date): Cannot enable auto-merge without GitHub CLI"
        return 1
    fi
}

# Monitor loop
for i in {1..10}; do
    echo "$(date): Check iteration $i/10"
    
    check_pr_status
    
    # Check if we should enable auto-merge
    if command -v gh &> /dev/null; then
        PR_STATE=$(gh pr view ${PR_NUMBER} --repo ${OWNER}/${REPO} --json state,reviewDecision --jq '.state + ":" + (.reviewDecision // "PENDING")')
        echo "$(date): PR State: ${PR_STATE}"
        
        if [[ "${PR_STATE}" == "OPEN:APPROVED" ]] || [[ "${PR_STATE}" == "OPEN:REVIEW_REQUIRED" ]]; then
            echo "$(date): PR is ready for auto-merge"
            if enable_auto_merge; then
                echo "$(date): Auto-merge enabled successfully"
                break
            fi
        fi
    fi
    
    echo "$(date): Waiting 30 seconds before next check..."
    sleep 30
done

echo "$(date): PR monitoring completed"
