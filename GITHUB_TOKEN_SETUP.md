# GitHub Token Setup Guide

## Overview

This guide explains how to set up GitHub Personal Access Tokens (PATs) for use with GitHub CLI and API integrations. You'll learn about the different token types, why classic tokens are sometimes required, and how to create both types of tokens.

## Why Classic Tokens Are Required

While GitHub's newer fine-grained Personal Access Tokens offer better security through repository-specific permissions, **classic tokens are still required for certain GitHub APIs**, particularly:

- **Notifications API**: GitHub's notifications endpoint (`/notifications`) does not currently support fine-grained PATs
- **User-level operations**: Some user-scoped operations require classic token permissions
- **Legacy integrations**: Older GitHub integrations may only work with classic tokens

> **Important**: Until GitHub fully migrates all APIs to support fine-grained tokens, you may need both token types for complete functionality.

## Token Types Explained

### Classic Personal Access Tokens (PATs)
- **Scope**: Account-wide access across all repositories
- **Permissions**: Broad, predefined scopes (repo, user, notifications, etc.)
- **Security**: Less granular but widely supported
- **Best for**: Notifications, user operations, legacy integrations

### Fine-Grained Personal Access Tokens
- **Scope**: Repository-specific access
- **Permissions**: Granular, resource-level permissions
- **Security**: More secure with minimal access principle
- **Best for**: Repository operations, modern integrations

## Required Token Types and Their Purposes

For full GitHub integration, you typically need:

1. **Classic Token** (for notifications and user operations)
   - Scopes needed: `notifications`, `read:user`, `repo` (if accessing private repos)

2. **Fine-Grained Token** (for repository operations)
   - Repository access: Specific repositories you work with
   - Permissions: Contents (read/write), Issues (read/write), Pull requests (read/write)

## Step-by-Step Token Creation

### Creating a Classic Personal Access Token

1. **Navigate to GitHub Settings**
   - Go to [GitHub.com](https://github.com) and sign in
   - Click your profile picture in the top-right corner
   - Select "Settings" from the dropdown menu

2. **Access Developer Settings**
   - Scroll down the left sidebar to "Developer settings" (bottom section)
   - Click "Personal access tokens"
   - Select "Tokens (classic)"

3. **Generate New Token**
   - Click "Generate new token" button
   - Select "Generate new token (classic)" from dropdown

4. **Configure Token Settings**
   ```
   Note: Descriptive name (e.g., "CLI and Notifications Access")
   Expiration: Choose appropriate timeframe (30-90 days recommended)
   ```

5. **Select Required Scopes**
   For notifications and general use, select these scopes:
   - ✅ `notifications` - Access notifications
   - ✅ `read:user` - Read user profile data  
   - ✅ `repo` - Full repository access (if you need private repo access)
   - ✅ `read:org` - Read organization data (if working with orgs)

   > 📸 *Screenshot reference: classic-token-scopes.png*

6. **Generate and Save Token**
   - Click "Generate token" at the bottom
   - **Important**: Copy the token immediately - you won't see it again!
   - Store it securely (password manager recommended)

### Creating a Fine-Grained Personal Access Token

1. **Access Fine-Grained Tokens**
   - From "Personal access tokens" page
   - Click "Fine-grained tokens" tab

2. **Generate New Fine-Grained Token**
   - Click "Generate new token"

3. **Configure Basic Settings**
   ```
   Token name: Descriptive name (e.g., "Repository Operations")
   Expiration: Choose timeframe
   Description: Optional description of token purpose
   ```

4. **Select Resource Access**
   - **Selected repositories**: Choose specific repositories
   - Or **All repositories**: If you need broad access (less secure)

   > 📸 *Screenshot reference: fine-grained-token-repos.png*

5. **Configure Repository Permissions**
   Set these permissions as needed:
   ```
   Repository permissions:
   - Contents: Read and write (for code operations)
   - Issues: Read and write (for issue management)  
   - Pull requests: Read and write (for PR operations)
   - Metadata: Read (always required)
   - Actions: Read (for workflow information)
   ```

   > 📸 *Screenshot reference: fine-grained-token-permissions.png*

6. **Generate and Save Token**
   - Review your settings
   - Click "Generate token"
   - Copy and store the token securely

## Token Storage and Usage

### Secure Storage
```bash
# Store in environment variables (recommended)
export GITHUB_TOKEN="ghp_your_classic_token_here"
export GITHUB_FINE_GRAINED_TOKEN="github_pat_your_fine_grained_token"
```

### GitHub CLI Configuration
```bash
# Authenticate with GitHub CLI using classic token
gh auth login --with-token < echo "your_classic_token"

# Verify authentication
gh auth status
```

### API Usage Examples
```bash
# Using classic token for notifications
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/notifications

# Using fine-grained token for repository operations  
curl -H "Authorization: token $GITHUB_FINE_GRAINED_TOKEN" \
     https://api.github.com/repos/owner/repo/issues
```

## Common Troubleshooting Scenarios

### 1. "Bad credentials" Error
**Symptoms**: 401 Unauthorized responses
**Causes**:
- Expired token
- Incorrect token format
- Wrong token type for the API

**Solutions**:
```bash
# Check token expiration in GitHub Settings
# Verify token format (classic: ghp_, fine-grained: github_pat_)
# Ensure you're using the right token for the API
```

### 2. "Insufficient Permissions" Error
**Symptoms**: 403 Forbidden responses
**Causes**:
- Missing required scopes/permissions
- Fine-grained token doesn't have repository access

**Solutions**:
- For classic tokens: Add required scopes (repo, notifications, etc.)
- For fine-grained tokens: Add repository to resource access
- Check repository permissions are sufficient

### 3. Notifications API Not Working
**Symptoms**: Cannot access `/notifications` endpoint
**Cause**: Using fine-grained token instead of classic token

**Solution**:
```bash
# Use classic token for notifications
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/notifications
```

### 4. Repository Operations Failing
**Symptoms**: Cannot access repository data/operations
**Causes**:
- Fine-grained token not granted repository access
- Missing repository permissions

**Solutions**:
1. Add repository to fine-grained token's resource access
2. Grant required repository permissions:
   - Contents: Read/Write
   - Issues: Read/Write  
   - Pull requests: Read/Write

### 5. Token Validation Issues
**Quick validation commands**:
```bash
# Test classic token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Test fine-grained token  
curl -H "Authorization: token $GITHUB_FINE_GRAINED_TOKEN" \
     https://api.github.com/repos/owner/repo
```

### 6. Organization Access Issues
**Symptoms**: Cannot access organization repositories
**Cause**: Organization hasn't approved fine-grained tokens

**Solution**:
1. Ask organization admin to enable fine-grained PAT access
2. Or use classic token with `read:org` scope

## Security Best Practices

### Token Management
- ✅ Use descriptive names for tokens
- ✅ Set appropriate expiration dates (30-90 days)
- ✅ Regularly review and rotate tokens
- ✅ Revoke unused tokens immediately
- ✅ Store tokens in secure password managers

### Permission Principles  
- ✅ Use fine-grained tokens when possible
- ✅ Grant minimal required permissions
- ✅ Prefer repository-specific access over account-wide
- ✅ Regular audit of token permissions

### Environment Security
```bash
# Use environment variables instead of hardcoding
export GITHUB_TOKEN="$(security find-generic-password -s github -w)"

# Never commit tokens to version control
echo "GITHUB_TOKEN=*" >> .gitenv
```

## Token Comparison Summary

| Feature | Classic PAT | Fine-Grained PAT |
|---------|-------------|------------------|
| **Scope** | Account-wide | Repository-specific |
| **Permissions** | Broad scopes | Granular permissions |
| **Notifications API** | ✅ Supported | ❌ Not supported |
| **Repository Operations** | ✅ Supported | ✅ Supported |
| **Security** | Good | Better |
| **Setup Complexity** | Simple | More complex |
| **Org Approval** | Not required | May be required |

## Quick Reference Commands

```bash
# List your tokens (via web interface only)
# https://github.com/settings/personal-access-tokens/tokens

# Test token validity
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/rate_limit

# View token scopes (classic tokens only)
curl -H "Authorization: token YOUR_CLASSIC_TOKEN" -I https://api.github.com/user

# GitHub CLI token status
gh auth status
```

---

## Need Help?

- **GitHub Documentation**: [Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- **GitHub Support**: [Contact GitHub Support](https://support.github.com/)
- **Community**: [GitHub Community Discussions](https://github.community/)

---

*Last updated: [Current Date] - Always check GitHub's latest documentation for the most current information.*
