#!/bin/bash

# GitHub Token Setup Script
# This script helps you securely store GitHub tokens using Docker MCP secret management
# Requires Docker and docker-mcp-gateway to be installed and running

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# Function to check if docker is available and running
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running or not accessible"
        print_error "Please start Docker and ensure you have proper permissions"
        exit 1
    fi
}

# Function to check if docker mcp secret command is available
check_docker_mcp() {
    if ! docker mcp secret --help &> /dev/null; then
        print_error "Docker MCP secret command is not available"
        print_error "Please ensure docker-mcp-gateway is installed and configured"
        exit 1
    fi
}

# Function to check if a secret already exists
check_secret_exists() {
    local secret_name="$1"
    if docker mcp secret get "$secret_name" &> /dev/null; then
        return 0  # Secret exists
    else
        return 1  # Secret does not exist
    fi
}

# Function to validate token format (basic check for GitHub personal access tokens)
validate_token() {
    local token="$1"
    local token_type="$2"
    
    # Check if token is empty
    if [[ -z "$token" ]]; then
        print_error "Token cannot be empty"
        return 1
    fi
    
    # Check token length (GitHub tokens are typically 40 characters for classic, or start with ghp_ for new format)
    if [[ ${#token} -lt 20 ]]; then
        print_warning "Token seems unusually short. GitHub tokens are typically longer."
        echo -n "Continue anyway? [y/N]: "
        read -r continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    # Check for common token prefixes
    if [[ "$token" =~ ^(ghp_|github_pat_) ]]; then
        print_status "Detected new format GitHub token"
    elif [[ "$token" =~ ^[a-f0-9]{40}$ ]]; then
        print_status "Detected classic GitHub token format"
    else
        print_warning "Token format doesn't match typical GitHub token patterns"
        echo -n "Continue anyway? [y/N]: "
        read -r continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    return 0
}

# Function to securely read password/token
read_token() {
    local prompt="$1"
    local token
    
    echo -n "$prompt"
    read -rs token
    echo  # New line after hidden input
    echo "$token"
}

# Function to set a secret using docker mcp
set_secret() {
    local secret_name="$1"
    local secret_value="$2"
    
    if docker mcp secret set "$secret_name" "$secret_value" &> /dev/null; then
        print_success "Successfully stored $secret_name"
        return 0
    else
        print_error "Failed to store $secret_name"
        return 1
    fi
}

# Main function
main() {
    echo "=============================================="
    echo "         GitHub Token Setup Script"
    echo "=============================================="
    echo
    print_status "This script will help you securely store GitHub tokens using Docker MCP secret management"
    echo
    
    # Check prerequisites
    print_status "Checking prerequisites..."
    check_docker
    check_docker_mcp
    print_success "All prerequisites met"
    echo
    
    # Check existing secrets
    print_status "Checking for existing tokens..."
    
    GITHUB_TOKEN_EXISTS=false
    GITHUB_NOTIFICATIONS_TOKEN_EXISTS=false
    
    if check_secret_exists "GITHUB_TOKEN"; then
        GITHUB_TOKEN_EXISTS=true
        print_warning "GITHUB_TOKEN already exists"
    fi
    
    if check_secret_exists "GITHUB_NOTIFICATIONS_TOKEN"; then
        GITHUB_NOTIFICATIONS_TOKEN_EXISTS=true
        print_warning "GITHUB_NOTIFICATIONS_TOKEN already exists"
    fi
    
    if [[ "$GITHUB_TOKEN_EXISTS" == true && "$GITHUB_NOTIFICATIONS_TOKEN_EXISTS" == true ]]; then
        echo
        print_warning "Both tokens already exist. Do you want to update them?"
        echo -n "Update existing tokens? [y/N]: "
        read -r update_choice
        if [[ ! "$update_choice" =~ ^[Yy]$ ]]; then
            print_status "Exiting without changes"
            exit 0
        fi
    fi
    
    echo
    print_status "=== GitHub Token Setup ==="
    echo
    
    # Setup primary GitHub token
    if [[ "$GITHUB_TOKEN_EXISTS" == false ]] || [[ "$update_choice" =~ ^[Yy]$ ]]; then
        echo "Setting up primary GitHub token (GITHUB_TOKEN):"
        echo "This should be a GitHub Classic Personal Access Token with the following scopes:"
        echo "  - notifications (required for GitHub notifications)"
        echo "  - repo (if you need repository access)"
        echo "  - user (if you need user profile access)"
        echo
        echo "To create a token:"
        echo "1. Go to https://github.com/settings/tokens"
        echo "2. Click 'Generate new token (classic)'"
        echo "3. Select required scopes"
        echo "4. Copy the token"
        echo
        
        while true; do
            token=$(read_token "Enter your GitHub Classic Personal Access Token: ")
            
            if validate_token "$token" "primary"; then
                if set_secret "GITHUB_TOKEN" "$token"; then
                    break
                else
                    print_error "Failed to store token. Please try again."
                fi
            else
                print_error "Invalid token. Please try again."
            fi
            echo
        done
    else
        print_status "Skipping GITHUB_TOKEN (already exists)"
    fi
    
    echo
    
    # Setup backup/alternative GitHub token
    if [[ "$GITHUB_NOTIFICATIONS_TOKEN_EXISTS" == false ]] || [[ "$update_choice" =~ ^[Yy]$ ]]; then
        echo "Setting up backup/alternative GitHub token (GITHUB_NOTIFICATIONS_TOKEN):"
        echo "This is an optional backup token that can be used for:"
        echo "  - Fallback when primary token hits rate limits"
        echo "  - Dedicated notifications-only access"
        echo "  - Different permission scopes"
        echo
        echo -n "Do you want to set up a backup token? [y/N]: "
        read -r backup_choice
        
        if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
            while true; do
                token=$(read_token "Enter your backup GitHub token: ")
                
                if validate_token "$token" "backup"; then
                    if set_secret "GITHUB_NOTIFICATIONS_TOKEN" "$token"; then
                        break
                    else
                        print_error "Failed to store backup token. Please try again."
                    fi
                else
                    print_error "Invalid backup token. Please try again."
                fi
                echo
            done
        else
            print_status "Skipping backup token setup"
        fi
    else
        print_status "Skipping GITHUB_NOTIFICATIONS_TOKEN (already exists)"
    fi
    
    echo
    print_status "=== Setup Summary ==="
    
    # Verify stored secrets
    if check_secret_exists "GITHUB_TOKEN"; then
        print_success "✓ GITHUB_TOKEN is stored and accessible"
    else
        print_error "✗ GITHUB_TOKEN is not properly stored"
    fi
    
    if check_secret_exists "GITHUB_NOTIFICATIONS_TOKEN"; then
        print_success "✓ GITHUB_NOTIFICATIONS_TOKEN is stored and accessible"
    else
        print_status "○ GITHUB_NOTIFICATIONS_TOKEN is not set (optional)"
    fi
    
    echo
    print_status "=== Usage Instructions ==="
    echo "Your tokens are now stored securely using Docker MCP secret management."
    echo
    echo "To use these tokens in your applications:"
    echo "  • Access via MCP tools that support GitHub integration"
    echo "  • Use 'docker mcp secret get GITHUB_TOKEN' to retrieve (if needed)"
    echo "  • Use 'docker mcp secret get GITHUB_NOTIFICATIONS_TOKEN' for backup token"
    echo
    echo "To manage your secrets:"
    echo "  • List all secrets: docker mcp secret list"
    echo "  • Update a secret: docker mcp secret set SECRET_NAME new_value"
    echo "  • Remove a secret: docker mcp secret delete SECRET_NAME"
    echo
    print_success "GitHub token setup completed successfully!"
}

# Trap to clear any sensitive variables on exit
trap 'unset token' EXIT

# Run main function
main "$@"
