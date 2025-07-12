# PR Status Polling Scripts

This directory contains two scripts for continuous PR status polling to monitor CI status and handle auto-merge scenarios.

## Files

- `poll-pr-status.js` - Node.js version with built-in 5-minute interval polling
- `poll-pr-status.sh` - Bash script for use with cron
- `crontab-example.txt` - Example crontab configurations
- `README-pr-polling.md` - This documentation

## Features

Both scripts provide:
- ✅ Query CI status using `gh run list --pr $PR_NUMBER`
- ✅ Check if auto-merge is enabled on the PR
- ✅ Exit successfully when all checks pass and auto-merge is enabled
- ✅ Trigger error handling for CI failures
- ✅ Comprehensive logging with timestamps
- ✅ Graceful signal handling (SIGINT, SIGTERM)
- ✅ Notification comments on PR for status changes

## Usage

### Node.js Version (Recommended)

The Node.js script runs continuously with a built-in 5-minute polling interval:

```bash
# Set PR number and start polling
export PR_NUMBER=123
node poll-pr-status.js

# Or provide PR number as environment variable inline
PR_NUMBER=123 node poll-pr-status.js
```

**Advantages:**
- Single process that manages its own timing
- Built-in error handling and retry logic
- Graceful shutdown on signals
- Continuous logging to file and console

### Bash Script with Cron

The bash script is designed to be run via cron every 5 minutes:

```bash
# Run once manually
./poll-pr-status.sh 123

# Or with environment variable
export PR_NUMBER=123
./poll-pr-status.sh
```

**Cron Configuration:**
```cron
# Add to crontab (crontab -e)
*/5 * * * * cd /path/to/your/repo && ./poll-pr-status.sh 123 >> ./cron.log 2>&1
```

## Configuration

### Environment Variables

- `PR_NUMBER` - PR number to monitor (required)
- `LOG_FILE` - Path to log file (default: `./pr-status.log`)
- `MAX_RETRIES` - Maximum retry attempts (default: 3)
- `REPO_OWNER` - Repository owner (optional, uses current repo)
- `REPO_NAME` - Repository name (optional, uses current repo)

### Node.js Configuration

Edit the `CONFIG` object in `poll-pr-status.js`:

```javascript
const CONFIG = {
    PR_NUMBER: process.env.PR_NUMBER || null,
    POLL_INTERVAL: 5 * 60 * 1000, // 5 minutes
    MAX_RETRIES: 3,
    LOG_FILE: './pr-status.log'
};
```

## Exit Codes

- `0` - Success (all checks passed and auto-merge enabled)
- `1` - CI failures detected or configuration error

## Behavior

1. **Initial Check**: Query CI status for the specified PR
2. **Failure Detection**: If any workflows have failed/cancelled status:
   - Log failure details
   - Add comment to PR with failure notification
   - Exit with code 1
3. **Success Check**: If all workflows passed:
   - Check if auto-merge is enabled
   - If auto-merge enabled: Add success comment and exit with code 0
   - If auto-merge not enabled: Continue polling (Node.js) or exit (bash)
4. **Pending Status**: If workflows are still running:
   - Log pending status
   - Continue polling (Node.js) or exit for next cron run (bash)

## Examples

### Start Node.js Polling

```bash
# Start continuous polling for PR #456
export PR_NUMBER=456
node poll-pr-status.js

# Run in background
nohup node poll-pr-status.js > polling.log 2>&1 &

# Run with systemd or supervisor for production
```

### Cron Setup

```bash
# Edit crontab
crontab -e

# Add entry (replace paths and PR number)
*/5 * * * * cd /home/user/my-repo && export PR_NUMBER=123 && ./poll-pr-status.sh >> ./cron.log 2>&1
```

### Manual Testing

```bash
# Test the bash script once
./poll-pr-status.sh 123

# Test with verbose output
export PR_NUMBER=123
./poll-pr-status.sh

# Check logs
tail -f pr-status.log
```

## Requirements

- GitHub CLI (`gh`) installed and authenticated
- `jq` command-line JSON processor (for bash script)
- Node.js runtime (for Node.js script)
- Appropriate permissions to read PR and workflow status

## Troubleshooting

### Common Issues

1. **"gh not found"**: Install GitHub CLI or ensure it's in PATH
2. **"jq not found"**: Install jq (`brew install jq` or `apt-get install jq`)
3. **Authentication errors**: Run `gh auth login` to authenticate
4. **Permission denied**: Run `chmod +x poll-pr-status.sh`

### Debugging

Enable debug logging by setting environment variables:

```bash
export DEBUG=1
export LOG_FILE=./debug.log
./poll-pr-status.sh 123
```

### Logs

Both scripts log to:
- Console (stdout)
- Log file (default: `./pr-status.log`)

Log format: `[TIMESTAMP] MESSAGE`

## Security Notes

- Scripts use `mise exec --` to ensure proper environment
- No sensitive data is logged
- GitHub CLI handles authentication securely
- Scripts can be run with limited permissions

## Customization

### Modify Polling Interval

**Node.js:**
```javascript
POLL_INTERVAL: 2 * 60 * 1000, // 2 minutes
```

**Cron:**
```cron
*/2 * * * * ./poll-pr-status.sh 123  # Every 2 minutes
```

### Custom Notifications

Edit the `handle_failures()` and `handle_success()` functions to:
- Send Slack notifications
- Update external status boards
- Trigger additional workflows
- Send emails

### Additional CI Checks

Modify `query_pr_status()` to add custom logic for:
- Specific workflow requirements
- Code coverage thresholds
- Security scan results
- Performance benchmarks
