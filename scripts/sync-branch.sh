#!/bin/bash

# Branch Synchronization Script
# Implements Step 3: Branch synchronization in orchestration CLI
# Usage: ./scripts/sync-branch.sh [base_branch]

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

# Function to check if local branch is behind origin/main
check_branch_behind() {
    local base_branch="$1"
    local current_branch
    
    current_branch=$(git branch --show-current)
    log_info "Checking if '$current_branch' is behind 'origin/$base_branch'"
    
    # Method 1: Try using GitHub CLI API
    if command -v gh &> /dev/null && [[ -n "${GITHUB_TOKEN:-}" ]]; then
        log_info "Using GitHub CLI to check branch status..."
        local gh_status
        
        # Get repository info
        local repo_info
        repo_info=$(gh repo view --json owner,name)
        local owner=$(echo "$repo_info" | jq -r '.owner.login')
        local repo=$(echo "$repo_info" | jq -r '.name')
        
        # Compare branches
        gh_status=$(gh api "repos/$owner/$repo/compare/origin/$base_branch...$current_branch" --jq '.status' 2>/dev/null || echo "error")
        
        if [[ "$gh_status" != "error" ]]; then
            case "$gh_status" in
                "behind")
                    log_warning "Branch '$current_branch' is behind 'origin/$base_branch'"
                    return 0  # Behind - needs sync
                    ;;
                "ahead"|"identical")
                    log_success "Branch '$current_branch' is up to date with 'origin/$base_branch'"
                    return 1  # Up to date - no sync needed
                    ;;
                "diverged")
                    log_warning "Branch '$current_branch' has diverged from 'origin/$base_branch'"
                    return 0  # Diverged - needs sync
                    ;;
            esac
        else
            log_info "GitHub CLI check failed, falling back to git commands"
        fi
    else
        log_info "GitHub CLI not available or no token, using git fallback"
    fi
    
    # Method 2: Fallback to git fetch && git status
    log_info "Fetching latest changes from origin..."
    mise exec -- git fetch origin
    
    local merge_base
    local origin_commit
    local local_commit
    
    merge_base=$(git merge-base HEAD "origin/$base_branch" 2>/dev/null || echo "")
    origin_commit=$(git rev-parse "origin/$base_branch" 2>/dev/null || echo "")
    local_commit=$(git rev-parse HEAD)
    
    if [[ -z "$merge_base" || -z "$origin_commit" ]]; then
        log_error "Could not determine branch relationship with origin/$base_branch"
        return 1
    fi
    
    if [[ "$merge_base" == "$origin_commit" ]]; then
        log_success "Branch '$current_branch' is up to date with 'origin/$base_branch'"
        return 1  # Up to date
    elif [[ "$merge_base" == "$local_commit" ]]; then
        log_warning "Branch '$current_branch' is behind 'origin/$base_branch'"
        return 0  # Behind
    else
        log_warning "Branch '$current_branch' has diverged from 'origin/$base_branch'"
        return 0  # Diverged
    fi
}

# Function to auto-merge base branch into feature branch with error handling
auto_merge_base() {
    local base_branch="$1"
    local current_branch
    
    current_branch=$(git branch --show-current)
    log_info "Auto-merging 'origin/$base_branch' into '$current_branch'"
    
    # Use CLI error handler for merge operation
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd)"
    local error_handler="${script_dir}/bin/cli-error-handler"
    
    # Attempt merge with error handling
    if "$error_handler" -- mise exec -- git merge "origin/$base_branch" --no-edit; then
        log_success "Successfully merged 'origin/$base_branch' into '$current_branch'"
        return 0
    else
        local exit_code=$?
        case $exit_code in
            3) # Merge conflict
                log_error "Merge conflicts detected and handled by error handler"
                ;;
            *)
                log_error "Merge failed with exit code $exit_code"
                ;;
        esac
        return 1
    fi
}

# Function to handle merge conflicts
handle_conflicts() {
    local base_branch="$1"
    
    log_error "Merge conflicts detected. Aborting merge..."
    
    # Abort the merge
    mise exec -- git merge --abort
    
    log_info "Conflict details:"
    echo "=== Files that would conflict ==="
    git diff --name-only HEAD "origin/$base_branch" || true
    
    echo ""
    echo "=== Conflict summary ==="
    git diff --stat HEAD "origin/$base_branch" || true
    
    echo ""
    log_error "Auto-merge failed due to conflicts."
    log_info "To resolve manually:"
    echo "  1. git merge origin/$base_branch"
    echo "  2. Resolve conflicts in the listed files"
    echo "  3. git add <resolved-files>"
    echo "  4. git commit"
    
    return 1
}

# Function to push updates and verify
push_and_verify() {
    local current_branch
    
    current_branch=$(git branch --show-current)
    log_info "Pushing updates to 'origin/$current_branch'..."
    
    if mise exec -- git push origin "$current_branch"; then
        log_success "Successfully pushed to 'origin/$current_branch'"
    else
        log_error "Failed to push to remote"
        return 1
    fi
    
    # Verify push
    log_info "Verifying push..."
    mise exec -- git fetch origin
    
    local local_commit
    local remote_commit
    
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse "origin/$current_branch")
    
    if [[ "$local_commit" == "$remote_commit" ]]; then
        log_success "Push verification successful"
        return 0
    else
        log_error "Push verification failed - local and remote commits don't match"
        return 1
    fi
}

# Function to enforce coding standards
enforce_coding_standards() {
    log_info "Enforcing coding standards..."
    
    # Run lefthook if available
    if command -v lefthook &> /dev/null && [[ -f ".lefthook.yml" ]]; then
        log_info "Running lefthook pre-commit hooks..."
        if lefthook run pre-commit; then
            log_success "Coding standards check passed"
        else
            log_warning "Coding standards check had issues"
        fi
    fi
    
    # Run make commands if Makefile exists
    if [[ -f "Makefile" ]]; then
        log_info "Running make commands..."
        if make lint 2>/dev/null; then
            log_success "Make lint passed"
        else
            log_info "Make lint not available or failed"
        fi
    fi
}

# Main synchronization function
sync_branch() {
    local base_branch="${1:-main}"
    local current_branch
    
    current_branch=$(git branch --show-current)
    
    log_info "Starting branch synchronization..."
    log_info "Current branch: $current_branch"
    log_info "Base branch: $base_branch"
    
    # Step 1: Detect if local branch is behind origin/main
    if ! check_branch_behind "$base_branch"; then
        log_success "Branch is already up to date. No synchronization needed."
        return 0
    fi
    
    # Step 2: Auto-merge base into feature branch
    if auto_merge_base "$base_branch"; then
        log_success "Auto-merge completed successfully"
    else
        # Step 4: Fallback - handle conflicts
        handle_conflicts "$base_branch"
        return 1
    fi
    
    # Step 3: Push updates and verify
    if push_and_verify; then
        log_success "Push and verification completed"
    else
        log_error "Push or verification failed"
        return 1
    fi
    
    # Enforce coding standards
    enforce_coding_standards
    
    log_success "Branch synchronization completed successfully!"
    
    # Final status check
    log_info "Final git status:"
    mise exec -- git status
    
    log_info "Latest commit:"
    mise exec -- git log --oneline -1
}

# Function to display usage
show_usage() {
    cat << EOF
Usage: $0 [BASE_BRANCH]

Synchronize current feature branch with base branch (default: main).

This script will:
1. Detect if local branch is behind origin/BASE_BRANCH via gh api or git fetch
2. If behind, auto-merge base into feature branch using 'mise exec -- git merge origin/BASE_BRANCH'
3. Push updates and verify synchronization
4. If conflicts occur, abort and surface conflict details

Arguments:
  BASE_BRANCH    Base branch to sync with (default: main)

Examples:
  $0              # Sync with origin/main
  $0 develop      # Sync with origin/develop
  $0 main         # Sync with origin/main

Environment Variables:
  GITHUB_TOKEN    GitHub token for API access (optional, will fallback to git)

EOF
}

# Main script execution
main() {
    # Check arguments
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    local base_branch="${1:-main}"
    
    # Ensure we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not in a git repository"
        exit 1
    fi
    
    # Ensure we're not on the base branch
    local current_branch
    current_branch=$(git branch --show-current)
    
    if [[ "$current_branch" == "$base_branch" ]]; then
        log_error "Cannot sync base branch with itself. Switch to a feature branch first."
        exit 1
    fi
    
    # Run synchronization
    sync_branch "$base_branch"
}

# Execute main function with all arguments
main "$@"
