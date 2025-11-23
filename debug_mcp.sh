#!/bin/bash

# MCP Debug Helper Script
# Usage: ./debug_mcp.sh [lines]
# Tails the most recent MCP log file

MCP_LOG_DIR="/Users/temp/Library/Application Support/dev.warp.Warp-Preview/mcp"
LINES=${1:-50}  # Default to last 50 lines

echo "=== MCP Debug Helper ==="
echo "Looking for latest MCP log file..."

# Find the most recently modified log file
LATEST_LOG=$(ls -t "$MCP_LOG_DIR"/*.log 2>/dev/null | head -1)

if [ -z "$LATEST_LOG" ]; then
    echo "❌ No MCP log files found in: $MCP_LOG_DIR"
    exit 1
fi

echo "📄 Latest log file: $(basename "$LATEST_LOG")"
echo "📅 Modified: $(stat -f "%Sm" "$LATEST_LOG")"
echo "🔍 Showing last $LINES lines..."
echo "================================================"

tail -n "$LINES" "$LATEST_LOG"

echo "================================================"
echo "💡 To follow live: tail -f \"$LATEST_LOG\""
