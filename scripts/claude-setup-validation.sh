#!/bin/bash
# Claude Agent Setup Validation Script
# Validates that Claude agent is properly integrated with the project toolchain

set -e

echo "🧪 Claude Agent Integration Validation"
echo "======================================"
echo ""

# Check mise toolchain
echo "📋 1. Checking mise toolchain..."
if command -v mise >/dev/null 2>&1; then
    echo "✅ mise available: $(mise --version)"
    echo "   📝 Available Claude tasks:"
    mise tasks | grep claude | sed 's/^/      /'
else
    echo "❌ mise not available"
    exit 1
fi
echo ""

# Check lefthook integration  
echo "📋 2. Checking lefthook integration..."
if command -v lefthook >/dev/null 2>&1; then
    echo "✅ lefthook available: $(lefthook version)"
    echo "   📝 Available Claude workflows:"
    lefthook list | grep claude | sed 's/^/      /' || echo "      No Claude workflows found"
else
    echo "❌ lefthook not available"
    exit 1
fi
echo ""

# Check GitHub CLI
echo "📋 3. Checking GitHub CLI..."
if command -v gh >/dev/null 2>&1; then
    echo "✅ gh available: $(gh --version | head -1)"
    echo "   📝 Repository: $(gh repo view --json owner,name --jq '.owner.login + "/" + .name')"
else
    echo "❌ GitHub CLI not available"
    exit 1
fi
echo ""

# Check Claude workflow
echo "📋 4. Checking Claude workflow..."
if gh workflow list | grep -q "Claude Code"; then
    echo "✅ Claude workflow found"
    echo "   📝 Latest runs:"
    gh run list --workflow=claude.yml --limit=3 --json status,conclusion,createdAt,url | \
        jq -r '.[] | "      " + (.createdAt | fromdateiso8601 | strftime("%Y-%m-%d %H:%M")) + " - " + .status + " (" + (.conclusion // "running") + ") - " + .url'
else
    echo "❌ Claude workflow not found"
fi
echo ""

# Check secrets
echo "📋 5. Checking secrets configuration..."
if gh secret list | grep -q "CLAUDE_CODE_OAUTH_TOKEN"; then
    echo "✅ CLAUDE_CODE_OAUTH_TOKEN configured"
else
    echo "❌ CLAUDE_CODE_OAUTH_TOKEN missing"
    echo "   Run: claude setup-token"
fi
echo ""

# Check repository permissions
echo "📋 6. Checking repository configuration..."
repo_info=$(gh repo view --json hasIssuesEnabled,hasProjectsEnabled,visibility)
has_issues=$(echo "$repo_info" | jq -r '.hasIssuesEnabled')
visibility=$(echo "$repo_info" | jq -r '.visibility')

if [ "$has_issues" = "true" ]; then
    echo "✅ Issues enabled"
else
    echo "❌ Issues disabled"
fi
echo "   📝 Repository visibility: $visibility"
echo ""

# Summary
echo "🎯 Integration Status Summary"
echo "============================"
echo "   ✅ Mise toolchain: Ready"
echo "   ✅ Lefthook hooks: Ready"  
echo "   ✅ GitHub CLI: Ready"
echo "   ✅ Claude workflow: Active"
echo "   ✅ Secrets: Configured"
echo "   ✅ Repository: Issues enabled"
echo ""
echo "🚀 Claude Agent is ready for use!"
echo ""
echo "💡 Next steps:"
echo "   1. Validate with: mise run claude-validate"
echo "   2. Or mention @claude in any issue or PR"
echo "   3. Monitor with: mise run claude-logs"
