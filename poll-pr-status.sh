#!/bin/bash

# PR Status Polling Script for Cron
# Usage: ./poll-pr-status.sh [PR_NUMBER]
# Environment variables:
#   PR_NUMBER - PR number to monitor
#   REPO_OWNER - Repository owner (optional, defaults to current repo)
#   REPO_NAME - Repository name (optional, defaults to current repo)

set -euo pipefail

# Configuration
PR_NUMBER="${1:-${PR_NUMBER:-}}"
LOG_FILE="${LOG_FILE:-./pr-status.log}"
MAX_RETRIES="${MAX_RETRIES:-3}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[${timestamp}] ${message}" | tee -a "${LOG_FILE}"
}

# Error logging function
log_error() {
    local message="$1"
    log "${RED}ERROR: ${message}${NC}"
}

# Success logging function
log_success() {
    local message="$1"
    log "${GREEN}SUCCESS: ${message}${NC}"
}

# Warning logging function
log_warning() {
    local message="$1"
    log "${YELLOW}WARNING: ${message}${NC}"
}

# Check if required tools are available
check_requirements() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is not installed or not in PATH"
        exit 1
    fi
}

# Validate PR number
validate_pr_number() {
    if [[ -z "${PR_NUMBER}" ]]; then
        log_error "PR_NUMBER not provided. Usage: $0 [PR_NUMBER] or set PR_NUMBER environment variable"
        exit 1
    fi
    
    if ! [[ "${PR_NUMBER}" =~ ^[0-9]+$ ]]; then
        log_error "PR_NUMBER must be a valid number. Got: ${PR_NUMBER}"
        exit 1
    fi
}

# Check if PR has auto-merge enabled
check_auto_merge() {
    local pr_number="$1"
    
    log "Checking auto-merge status for PR #${pr_number}"
    
    local auto_merge_data
    if ! auto_merge_data=$(mise exec -- gh pr view "${pr_number}" --json autoMergeRequest 2>/dev/null); then
        log_error "Failed to check auto-merge status for PR #${pr_number}"
        return 1
    fi
    
    local auto_merge_enabled
    auto_merge_enabled=$(echo "${auto_merge_data}" | jq -r '.autoMergeRequest != null')
    
    if [[ "${auto_merge_enabled}" == "true" ]]; then
        log "Auto-merge is enabled for PR #${pr_number}"
        return 0
    else
        log "Auto-merge is not enabled for PR #${pr_number}"
        return 1
    fi
}

# Query CI status for PR
query_pr_status() {
    local pr_number="$1"
    
    log "Querying CI status for PR #${pr_number}"
    
    local runs_data
    if ! runs_data=$(mise exec -- gh run list --pr "${pr_number}" --json status,conclusion,workflowName 2>/dev/null); then
        log_error "Failed to query workflow runs for PR #${pr_number}"
        return 1
    fi
    
    local total_runs
    total_runs=$(echo "${runs_data}" | jq length)
    
    if [[ "${total_runs}" -eq 0 ]]; then
        log "No CI runs found for PR #${pr_number}"
        echo "no_runs"
        return 0
    fi
    
    local failed_runs
    failed_runs=$(echo "${runs_data}" | jq '[.[] | select(.conclusion == "failure" or .conclusion == "cancelled")] | length')
    
    local pending_runs
    pending_runs=$(echo "${runs_data}" | jq '[.[] | select(.status == "in_progress" or .status == "queued")] | length')
    
    local success_runs
    success_runs=$(echo "${runs_data}" | jq '[.[] | select(.conclusion == "success")] | length')
    
    log "Status summary: ${success_runs} successful, ${failed_runs} failed, ${pending_runs} pending"
    
    if [[ "${failed_runs}" -gt 0 ]]; then
        local failed_workflows
        failed_workflows=$(echo "${runs_data}" | jq -r '[.[] | select(.conclusion == "failure" or .conclusion == "cancelled") | .workflowName] | join(", ")')
        log_error "Failed workflows: ${failed_workflows}"
        echo "failed:${failed_workflows}"
        return 0
    elif [[ "${pending_runs}" -gt 0 ]]; then
        log "CI checks still pending (${pending_runs} pending)"
        echo "pending"
        return 0
    else
        log_success "All CI checks passed (${success_runs} successful)"
        echo "success"
        return 0
    fi
}

# Handle CI failures
handle_failures() {
    local pr_number="$1"
    local failed_workflows="$2"
    
    log_error "CI FAILURES DETECTED for PR #${pr_number}"
    log_error "Failed workflows: ${failed_workflows}"
    
# Send notification comment to PR using CLI error handler
    local comment_body="❌ CI failures detected in workflows: ${failed_workflows}"
    
    # Use CLI error handler for robust GitHub comment posting with retry
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)"
    local error_handler="${script_dir}/bin/cli-error-handler"
    
    if "$error_handler" --retry --pr-number "${pr_number}" -- gh pr comment "${pr_number}" --body "${comment_body}"; then
        log "Failure notification sent to PR #${pr_number}"
    else
        log_error "Failed to send notification comment to PR #${pr_number} after retries"
    fi
    
    # Exit with error code
    exit 1
}

# Handle successful completion
handle_success() {
    local pr_number="$1"
    
    log_success "All CI checks passed and auto-merge is enabled for PR #${pr_number}"
    log_success "PR is ready for auto-merge - exiting polling"
    
    # Optional: Add success comment
    local comment_body="✅ All CI checks passed! Auto-merge will proceed."
    
    if mise exec -- gh pr comment "${pr_number}" --body "${comment_body}" 2>/dev/null; then
        log "Success notification sent to PR #${pr_number}"
    else
        log_warning "Failed to send success notification to PR #${pr_number}"
    fi
    
    exit 0
}

# Main polling function
main() {
    log "=== PR Status Polling Script Started ==="
    log "PR Number: ${PR_NUMBER}"
    log "Log File: ${LOG_FILE}"
    
    # Check requirements
    check_requirements
    
    # Validate PR number
    validate_pr_number
    
    # Query PR status
    local status_result
    status_result=$(query_pr_status "${PR_NUMBER}")
    
    case "${status_result}" in
        "no_runs")
            log "No CI runs found - assuming ready"
            if check_auto_merge "${PR_NUMBER}"; then
                handle_success "${PR_NUMBER}"
            else
                log "Auto-merge not enabled - nothing to do"
                exit 0
            fi
            ;;
        "failed:"*)
            local failed_workflows="${status_result#failed:}"
            handle_failures "${PR_NUMBER}" "${failed_workflows}"
            ;;
        "pending")
            log "CI checks still pending - will check again in next poll"
            exit 0
            ;;
        "success")
            log "All CI checks passed"
            if check_auto_merge "${PR_NUMBER}"; then
                handle_success "${PR_NUMBER}"
            else
                log "Auto-merge not enabled - continuing to monitor"
                exit 0
            fi
            ;;
        *)
            log_error "Unknown status result: ${status_result}"
            exit 1
            ;;
    esac
}

# Signal handling
trap 'log "Received signal - shutting down gracefully"; exit 0' SIGINT SIGTERM

# Run main function
main "$@"
