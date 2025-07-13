#!/bin/bash

# Automated Code Review Script
# This script demonstrates the complete workflow for automating code review with local LLM

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
🤖 Automated Code Review with Local LLM

USAGE:
    $0 --owner <owner> --repo <repo> --pr <pr_number> [options]

OPTIONS:
    --owner     Repository owner (required)
    --repo      Repository name (required) 
    --pr        Pull request number (required)
    --dry-run   Run analysis only, don't submit review
    --demo      Show MCP tool call examples
    --help      Show this help message

EXAMPLES:
    # Run full automated review
    $0 --owner jcowhigjr --repo yelp_search_demo --pr 808

    # Dry run (analysis only)
    $0 --owner jcowhigjr --repo yelp_search_demo --pr 808 --dry-run

    # Show MCP call examples
    $0 --owner jcowhigjr --repo yelp_search_demo --pr 808 --demo

REQUIREMENTS:
    - Python 3.7+
    - mise for environment management
    - Local LLM (Ollama recommended) or fallback to rule-based analysis
    - MCP tools for GitHub integration

WORKFLOW:
    1. Extract PR diff via 'gh pr diff' or MCP get_pull_request_diff
    2. Feed diff to local LLM for review comments  
    3. Use MCP create_pending_pull_request_review
    4. Use MCP add_pull_request_review_comment_to_pending_review
    5. Use MCP submit_pending_pull_request_review
    6. Verify with MCP get_pull_request_reviews

EOF
}

# Parse command line arguments
OWNER=""
REPO=""
PR=""
DRY_RUN=false
DEMO=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --owner)
            OWNER="$2"
            shift 2
            ;;
        --repo)
            REPO="$2"
            shift 2
            ;;
        --pr)
            PR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --demo)
            DEMO=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$OWNER" || -z "$REPO" || -z "$PR" ]]; then
    print_error "Missing required arguments"
    show_usage
    exit 1
fi

# Check if we're in the right directory
if [[ ! -f "mise.toml" ]]; then
    print_warning "No mise.toml found. Make sure you're in the project root."
fi

print_step "🚀 Starting Automated Code Review"
echo "Repository: $OWNER/$REPO"
echo "Pull Request: #$PR"
echo "Mode: $([ "$DRY_RUN" = true ] && echo "DRY RUN" || echo "FULL REVIEW")"
echo "=" $(printf '=%.0s' {1..50})

# Step 1: Check dependencies
print_step "🔍 Checking dependencies..."

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is required but not found"
    exit 1
fi

# Check if mise is available and working
if ! command -v mise &> /dev/null; then
    print_error "mise is required but not found"
    exit 1
fi

print_success "Dependencies check passed"

# Step 2: Check for local LLM availability
print_step "🤖 Checking local LLM availability..."

LLM_AVAILABLE=false

# Check for Ollama
if command -v ollama &> /dev/null; then
    if ollama list 2>/dev/null | grep -q "llama"; then
        print_success "Ollama with Llama model found"
        LLM_AVAILABLE=true
    else
        print_warning "Ollama found but no Llama model available"
    fi
else
    print_warning "Ollama not found"
fi

# Check for other local LLM services
if curl -s http://localhost:8080/health &> /dev/null; then
    print_success "LocalAI service found on port 8080"
    LLM_AVAILABLE=true
elif curl -s http://localhost:1234/health &> /dev/null; then
    print_success "LM Studio service found on port 1234"
    LLM_AVAILABLE=true
fi

if [ "$LLM_AVAILABLE" = false ]; then
    print_warning "No local LLM found. Will use rule-based analysis as fallback."
fi

# Step 3: Run the appropriate script
print_step "📋 Running code review workflow..."

if [ "$DEMO" = true ]; then
    print_step "🔧 Showing MCP tool call examples..."
    mise exec -- python mcp_code_review.py --owner "$OWNER" --repo "$REPO" --pr "$PR" --demo-calls
elif [ "$DRY_RUN" = true ]; then
    print_step "🧪 Running dry run analysis..."
    mise exec -- python automated_code_review.py --owner "$OWNER" --repo "$REPO" --pr "$PR" --dry-run
else
    print_step "🚀 Running full MCP-integrated review..."
    mise exec -- python mcp_code_review.py --owner "$OWNER" --repo "$REPO" --pr "$PR"
fi

# Check exit status
if [ $? -eq 0 ]; then
    print_success "✅ Automated code review completed successfully!"
    
    if [ "$DRY_RUN" = false ] && [ "$DEMO" = false ]; then
        echo ""
        print_step "📋 Next Steps:"
        echo "   • Visit: https://github.com/$OWNER/$REPO/pull/$PR"
        echo "   • Review the automated comments"
        echo "   • Address any security or critical issues"
        echo "   • Merge when ready!"
        echo ""
        print_step "🔄 To run analysis only:"
        echo "   $0 --owner $OWNER --repo $REPO --pr $PR --dry-run"
    fi
else
    print_error "❌ Automated code review failed"
    exit 1
fi

print_success "🎉 All done!"
