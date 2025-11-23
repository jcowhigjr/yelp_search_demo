#!/usr/bin/env bash
# Application monitoring script for deployment verification and health checks

set -eo pipefail

# Configuration
APP_URL="${APP_URL:-https://dorkbob.herokuapp.com}"
HEALTH_ENDPOINT="${HEALTH_ENDPOINT:-/healthz}"
CHECK_INTERVAL="${CHECK_INTERVAL:-30}"
MAX_RETRIES="${MAX_RETRIES:-3}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️ $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
}

check_health() {
    local url="$APP_URL$HEALTH_ENDPOINT"
    local retry_count=0
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        log "Checking health endpoint: $url (attempt $((retry_count + 1))/$MAX_RETRIES)"
        
        # Perform health check with curl
        if response=$(curl -s -w "HTTPSTATUS:%{http_code};TIME:%{time_total}" "$url" 2>/dev/null); then
            http_code=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
            response_time=$(echo "$response" | grep -o "TIME:[0-9.]*" | cut -d: -f2)
            body=$(echo "$response" | sed -E 's/HTTPSTATUS:[0-9]*;TIME:[0-9.]*$//')
            
            if [ "$http_code" = "200" ] && [ "$body" = "OK" ]; then
                success "Health check passed - Status: $http_code, Response time: ${response_time}s"
                return 0
            else
                warning "Health check failed - Status: $http_code, Body: '$body', Response time: ${response_time}s"
            fi
        else
            warning "Failed to connect to health endpoint"
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $MAX_RETRIES ]; then
            log "Retrying in 5 seconds..."
            sleep 5
        fi
    done
    
    error "Health check failed after $MAX_RETRIES attempts"
    return 1
}

check_deployment_status() {
    log "Checking deployment status..."
    
    # Check git status
    log "Current git status:"
    git log --oneline -5
    
    # Check if we're on develop branch
    current_branch=$(git branch --show-current)
    if [ "$current_branch" = "develop" ]; then
        success "On develop branch (deployment branch)"
    else
        warning "Not on develop branch (current: $current_branch)"
    fi
    
    # Check for uncommitted changes
    if git diff-index --quiet HEAD --; then
        success "No uncommitted changes"
    else
        warning "There are uncommitted changes"
        git status --porcelain
    fi
}

check_recent_workflows() {
    log "Checking recent CI/CD workflow status..."
    
    if command -v gh >/dev/null 2>&1; then
        gh run list --repo jcowhigjr/yelp_search_demo --limit 3 --json status,conclusion,displayTitle,createdAt --template '{{range .}}{{.displayTitle}}: {{.status}}/{{.conclusion}} ({{timeago .createdAt}}){{"\n"}}{{end}}'
    else
        warning "GitHub CLI not available - skipping workflow status check"
    fi
}

monitor_continuous() {
    log "Starting continuous monitoring (interval: ${CHECK_INTERVAL}s)"
    log "Press Ctrl+C to stop"
    
    while true; do
        echo
        log "--- Monitoring cycle started ---"
        
        if check_health; then
            success "Application is healthy"
        else
            error "Application health check failed!"
            
            # Optional: Send alert or perform recovery actions
            if [ -n "$SLACK_WEBHOOK_URL" ]; then
                curl -X POST -H 'Content-type: application/json' \
                    --data '{"text":"🚨 Application health check failed for '"$APP_URL"'"}' \
                    "$SLACK_WEBHOOK_URL" >/dev/null 2>&1 || true
            fi
        fi
        
        log "Waiting ${CHECK_INTERVAL} seconds before next check..."
        sleep "$CHECK_INTERVAL"
    done
}

show_help() {
    echo "Application Monitoring Script"
    echo
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  health     - Check application health once"
    echo "  status     - Check deployment status"
    echo "  workflows  - Check recent CI/CD workflow runs"
    echo "  monitor    - Start continuous monitoring"
    echo "  help       - Show this help message"
    echo
    echo "Environment Variables:"
    echo "  APP_URL           - Application URL (default: https://dorkbob.herokuapp.com)"
    echo "  HEALTH_ENDPOINT   - Health check endpoint (default: /healthz)"
    echo "  CHECK_INTERVAL    - Monitoring interval in seconds (default: 30)"
    echo "  MAX_RETRIES       - Maximum retry attempts (default: 3)"
    echo "  SLACK_WEBHOOK_URL - Slack webhook for alerts (optional)"
}

# Main script logic
case "${1:-help}" in
    health)
        check_health
        ;;
    status)
        check_deployment_status
        ;;
    workflows)
        check_recent_workflows
        ;;
    monitor)
        monitor_continuous
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Unknown command: $1"
        echo
        show_help
        exit 1
        ;;
esac
