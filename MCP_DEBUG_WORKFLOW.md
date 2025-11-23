# MCP Debugging Workflow

## Rule: When MCP Tool Calls Fail

**If any MCP tool call fails, automatically run the MCP debug helper to get more context on the failure.**

### Quick Commands

1. **Check latest MCP logs:**
   ```bash
   ./debug_mcp.sh
   ```

2. **Follow live MCP logs:**
   ```bash
   tail -f "/Users/temp/Library/Application Support/dev.warp.Warp-Preview/mcp/q7k5RKzbgu6EAiFkNbSYJH.log"
   ```

3. **Check all available log files:**
   ```bash
   ls -la "/Users/temp/Library/Application Support/dev.warp.Warp-Preview/mcp/"*.log
   ```

### Debugging Process

When an MCP tool fails:

1. ✅ **Immediately run:** `./debug_mcp.sh` 
2. ✅ **Analyze the error** in the log output
3. ✅ **Check authentication/permissions** if it's a 403/401 error  
4. ✅ **Verify tool parameters** if it's a 400/422 error
5. ✅ **Check network connectivity** if it's a timeout/connection error

### Common MCP Issues

- **403 Forbidden:** Token missing required scopes
- **404 Not Found:** Repository/resource doesn't exist or incorrect name
- **401 Unauthorized:** Token invalid or expired
- **422 Unprocessable Entity:** Invalid parameters or request format
- **Connection timeouts:** Network or API rate limiting issues

---

This workflow helps debug issues with `warp-ai mcp` commands effectively.
