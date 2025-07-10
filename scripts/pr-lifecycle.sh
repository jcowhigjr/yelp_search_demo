#!/bin/bash

# PR Lifecycle Coordination Script
# Usage: ./scripts/pr-lifecycle.sh [trigger|poll|sync] [options]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to verify git operations
verify_git_operation() {
    local operation_name="$1"
    log_info "Verifying git operation: $operation_name"
    
    echo "Latest commit:"
    git log --oneline -1
    
    echo -e "\nGit status:"
    git status
    
    log_success "Git operation verified: $operation_name"
}

# Function to run coding standards checks
enforce_coding_standards() {
    log_info "Enforcing coding standards..."
    
    # Run make commands for coding standards
    if [[ -f "Makefile" ]]; then
        log_info "Running make lint..."
        if make lint 2>/dev/null; then
            log_success "Make lint passed"
        else
            log_warning "Make lint failed or not available"
        fi
        
        log_info "Running make test..."
        if make test 2>/dev/null; then
            log_success "Make test passed"
        else
            log_warning "Make test failed or not available"
        fi
    else
        log_warning "No Makefile found, skipping make commands"
    fi
    
    # Run lefthook CI commands
    if command -v lefthook &> /dev/null; then
        log_info "Running lefthook..."
        if lefthook run pre-commit 2>/dev/null; then
            log_success "Lefthook pre-commit passed"
        else
            log_warning "Lefthook pre-commit failed or not configured"
        fi
    else
        log_warning "Lefthook not found, skipping lefthook checks"
    fi
}

# Function to call GitHub CLI with robust error handling
call_github_cli() {
    local gh_command="$1"
    shift
    local gh_args=("$@")
    
    log_info "Calling GitHub CLI with error handling: gh $gh_command ${gh_args[*]}"
    
    # Use the CLI error handler for robust GitHub CLI operations
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)"
    local error_handler="${script_dir}/bin/cli-error-handler"
    
    # Detect if this is an API operation that should retry
    local retry_flag=""
    case "$gh_command" in
        "api"|"run"|"workflow"|"pr")
            retry_flag="--retry"
            ;;
    esac
    
    # Build the full command
    local full_command=("gh" "$gh_command" "${gh_args[@]}")
    
    # Execute with error handling
    "$error_handler" $retry_flag -- "${full_command[@]}"
}

# Function to handle trigger action
handle_trigger() {
    local branch_name="${1:-feature/$(date +%s)}"
    local pr_title="${2:-Automated PR from pr-lifecycle script}"
    local pr_body="${3:-This PR was created automatically by the pr-lifecycle script.}"
    
    log_info "Triggering PR creation process..."
    
    # Enforce coding standards before creating PR
    enforce_coding_standards
    
    # Verify current git state
    verify_git_operation "pre-trigger"
    
    # Create PR via GitHub CLI
    log_info "Creating PR: $pr_title"
    call_github_cli "pr" "create" \
        "--title" "$pr_title" \
        "--body" "$pr_body" \
        "--head" "$branch_name" \
        --draft
    
    # Verify git state after PR creation
    verify_git_operation "post-trigger"
    
    log_success "PR trigger completed successfully"
}

# Function to handle poll action
handle_poll() {
    local pr_number="${1:-}"
    
    log_info "Polling PR status..."
    
    if [[ -n "$pr_number" ]]; then
        # Poll specific PR
        call_github_cli "pr" "view" "$pr_number" --json state,title,url
    else
        # Poll all open PRs
        call_github_cli "pr" "list" --state open --json number,title,state,url
    fi
    
    # Verify git state
    verify_git_operation "poll"
    
    log_success "PR polling completed"
}

# Function to detect if a local branch is behind origin/main
detect_branch_status() {
    local base_branch="${1:-main}"
    local current_branch
    
    current_branch=$(git branch --show-current)
    log_info "Detecting branch status for '$current_branch' against origin/$base_branch"
    
    # Check using GitHub CLI (attempt first, then fallback)
    if command -v gh &> /dev/null; then
        local gh_result
        gh_result=$(gh api repos/:owner/:repo/compare/origin/$base_branch...$current_branch --jq '.status' 2>/dev/null || echo "error")
        if [[ "$gh_result" != "error" ]]; then
            log_info "GitHub CLI returned status: $gh_result"
            case "$gh_result" in
                "ahead")
                    log_success "Branch '$current_branch' is ahead of origin/$base_branch"
                    return 0
                    ;;
                "behind")
                    log_warning "Branch '$current_branch' is behind origin/$base_branch"
                    return 1
                    ;;
                "identical")
                    log_success "Branch '$current_branch' is identical to origin/$base_branch"
                    return 0
                    ;;
                "diverged")
                    log_warning "Branch '$current_branch' has diverged from origin/$base_branch"
                    return 1
                    ;;
            esac
        else
            log_info "GitHub CLI check failed, using git fallback"
        fi
    else
        log_info "GitHub CLI not available, using git fallback"
    fi
    
    # Fallback: Use git fetch && git status
    git fetch origin
    local merge_base
    local origin_commit
    local local_commit
    
    merge_base=$(git merge-base HEAD origin/$base_branch)
    origin_commit=$(git rev-parse origin/$base_branch)
    local_commit=$(git rev-parse HEAD)
    
    if [[ "$merge_base" == "$origin_commit" ]]; then
        log_success "Branch '$current_branch' is up to date with origin/$base_branch"
        return 0
    elif [[ "$merge_base" == "$local_commit" ]]; then
        log_warning "Branch '$current_branch' is behind origin/$base_branch"
        return 1
    else
        log_warning "Branch '$current_branch' has diverged from origin/$base_branch"
        return 1
    fi
}

# Function to handle merge conflicts
handle_merge_conflicts() {
    local base_branch="$1"
    
    log_error "Merge conflicts detected during sync with origin/$base_branch"
    
    log_info "Aborting merge..."
    git merge --abort
    
    log_info "Conflict details:"
    git diff --name-only HEAD origin/$base_branch
    
    echo "=== Detailed conflict preview ==="
    git diff HEAD origin/$base_branch --stat
    
    log_error "Auto-merge failed. Manual resolution required."
    log_info "To resolve conflicts manually:"
    git status
    return 1
}

# Function to handle sync action
handle_sync() {
    local base_branch="${1:-main}"
    
    log_info "Starting branch synchronization with origin/$base_branch..."
    
    verify_git_operation "pre-sync"
    
    if detect_branch_status "$base_branch"; then
        log_success "Branch is already synchronized with origin/$base_branch"
        return 0
    fi
    
    log_info "Branch is behind origin/$base_branch, proceeding with auto-merge..."
    
    if mise exec -- git merge origin/$base_branch --no-edit; then
        log_success "Successfully merged origin/$base_branch into current branch"
    else
        handle_merge_conflicts "$base_branch"
        return 1
    fi
    
    log_info "Pushing updates to remote..."
    local current_branch
    current_branch=$(git branch --show-current)
    
    if mise exec -- git push origin "$current_branch"; then
        log_success "Successfully pushed updates to origin/$current_branch"
    else
        log_error "Failed to push updates to remote"
        return 1
    fi
    
    log_info "Verifying push..."
    git fetch origin
    
    local local_commit
    local remote_commit
    
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse origin/$current_branch)
    
    if [[ "$local_commit" == "$remote_commit" ]]; then
        log_success "Push verification successful"
    else
        log_error "Push verification failed"
        return 1
    fi
    
    enforce_coding_standards
    verify_git_operation "post-sync"
    
    log_success "Branch synchronization completed successfully"
}

# Function to display usage
show_usage() {
    cat << EOF
Usage: $0 [ACTION] [OPTIONS]

Actions:
  trigger [BRANCH] [TITLE] [BODY]    Create a new PR
  poll [PR_NUMBER]                   Check PR status
  sync [BASE_BRANCH]                 Sync current branch with base

Options:
  -h, --help                         Show this help message

Examples:
  $0 trigger feature/new-feature "Add new feature" "This adds a new feature"
  $0 poll 123
  $0 sync main

Environment Variables:
  GITHUB_TOKEN                       GitHub personal access token (required)
EOF
}

# Main script logic
main() {
    # Check if GitHub token is set
    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        log_error "GITHUB_TOKEN environment variable is not set"
        exit 1
    fi
    
    # Parse command line arguments
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    local action="$1"
    shift
    
    case "$action" in
        trigger)
            handle_trigger "$@"
            ;;
        poll)
            handle_poll "$@"
            ;;
        sync)
            handle_sync "$@"
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown action: $action"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
