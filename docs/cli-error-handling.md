# CLI Error Handling Implementation

This document describes the robust error handling system implemented for the CLI to catch all non-zero exits and handle them appropriately according to the requirements.

## Overview

The CLI error handling system provides:

1. **CI Failure Detection**: Automatically detects CI failures and posts detailed GitHub comments
2. **Merge Conflict Handling**: Detects merge conflicts, notifies locally, and aborts safely
3. **API Retry Logic**: Implements exponential backoff for transient API errors
4. **Comprehensive Logging**: Structured error classification and detailed logging

## Architecture

### Core Components

1. **`lib/cli_error_handler.rb`** - Ruby-based error handler with advanced features
2. **`bin/cli-error-handler`** - Shell wrapper for easy integration
3. **Enhanced shell scripts** - Updated existing scripts to use error handling

### Error Classification

The system automatically classifies errors into categories:

- **CI Failures**: Test failures, build failures, workflow failures
- **Merge Conflicts**: Git merge conflicts with detailed resolution guidance
- **API Errors**: GitHub API errors with retry logic for transient issues
- **General Errors**: All other command failures with comprehensive logging

## Usage Examples

### Basic Error Handling

```bash
# Simple command execution with error handling
bin/cli-error-handler -- ls /nonexistent

# CI operation with PR context
bin/cli-error-handler --pr-number 123 -- bin/rails test

# Merge operation with conflict detection
bin/cli-error-handler -- git merge origin/main
```

### API Operations with Retry

```bash
# GitHub API call with automatic retry on transient errors
bin/cli-error-handler --retry -- gh api repos/owner/repo

# PR creation with retry and custom configuration
bin/cli-error-handler --retry --max-retries 5 -- gh pr create --title "Test PR"

# Workflow operations with exponential backoff
bin/cli-error-handler --retry -- gh run list --repo owner/repo
```

### Integration with Existing Scripts

The error handler integrates seamlessly with existing project tools:

```bash
# lefthook CI operations
bin/cli-error-handler --pr-number "${PR_NUMBER}" -- CI=true RAILS_ENV=test mise exec -- bin/rails test

# Branch synchronization with merge conflict handling
bin/cli-error-handler -- mise exec -- git merge origin/main

# GitHub CLI operations with retry
bin/cli-error-handler --retry -- gh pr comment 123 --body "Test comment"
```

## Features

### 1. CI Failure Detection and Reporting

When CI failures are detected, the system:

- Extracts comprehensive failure details
- Posts a GitHub comment with:
  - Command that failed
  - Exit code and duration
  - Complete error output
  - Resolution steps
- Logs detailed failure information locally

**Example GitHub Comment:**

```markdown
## 🚨 CI Failure Detected

**Command:** `bin/rails test`
**Exit Code:** 1
**Duration:** 45.23s
**Timestamp:** 2024-01-15T10:30:00Z

### Error Summary
Test failures in UserTest#test_validation

### Error Details
```
1) Failure:
UserTest#test_validation [test/models/user_test.rb:25]:
Expected validation to fail but it passed
```

**Next Steps:**
1. Review the error details above
2. Fix the underlying issue
3. Re-run the failed command
4. Ensure all tests pass before requesting review

---
*This comment was generated automatically by the CLI error handler.*
```

### 2. Merge Conflict Detection and Handling

When merge conflicts are detected:

- Automatically aborts the merge operation
- Provides detailed local notification with:
  - List of conflicted files
  - Conflict markers found
  - Step-by-step resolution instructions
- Prevents repository corruption

**Example Local Output:**

```
============================================================
🚨 MERGE CONFLICT DETECTED
============================================================
Command: git merge origin/main
Summary: Merge conflict detected during: git merge origin/main
Timestamp: 2024-01-15T10:30:00Z

Conflicted Files:
  - app/models/user.rb
  - config/routes.rb

Conflict Markers Found:
  - <<<<<<< (conflict start)
  - ======= (conflict separator)  
  - >>>>>>> (conflict end)

Resolution Steps:
1. Review the conflicted files listed above
2. Edit files to resolve conflicts (remove <<<<<<, ======, >>>>>> markers)
3. Stage resolved files: git add <file>
4. Complete the merge: git commit
5. Or abort the merge: git merge --abort

Merge operation has been aborted to prevent corruption.
============================================================
```

### 3. API Error Retry with Exponential Backoff

For API operations, the system implements:

- **Transient Error Detection**: Identifies temporary issues like rate limits, timeouts, network errors
- **Exponential Backoff**: Delays between retries increase exponentially (1s, 2s, 4s, 8s...)
- **Maximum Retry Limit**: Configurable maximum retry attempts (default: 3)
- **Retry Exhaustion Notification**: Posts GitHub comment when retries are exhausted

**Retry Configuration:**

```bash
# Default retry (3 attempts, 1s base delay, 60s max delay)
bin/cli-error-handler --retry -- gh api repos/owner/repo

# Custom retry configuration
bin/cli-error-handler --retry --max-retries 5 -- gh pr create --title "Test"
```

**Transient Error Patterns:**

- Connection reset
- Timeout errors
- Rate limit exceeded
- Service unavailable
- Internal server error
- Bad gateway
- Gateway timeout
- Too many requests

### 4. Environment Integration

The error handler integrates with the project's environment:

- **mise Integration**: Uses `mise exec` for proper environment management
- **GitHub Token**: Automatically detects and uses `GITHUB_TOKEN`
- **PR Context**: Detects PR number from environment or GitHub CLI
- **Lefthook Integration**: Works seamlessly with existing CI/CD pipelines

## Configuration

### Environment Variables

- `GITHUB_TOKEN`: GitHub API token for comment posting
- `PR_NUMBER`: PR number for GitHub comments
- `CLI_ERROR_HANDLER_LOG`: Log level override (DEBUG, INFO, WARN, ERROR)

### Command Line Options

```bash
--retry                 # Enable retry logic for API operations
--max-retries COUNT     # Maximum retry attempts (default: 3)
--log-level LEVEL       # Log level: DEBUG, INFO, WARN, ERROR
--pr-number NUMBER      # PR number for GitHub comments
--dry-run              # Dry run mode - no GitHub comments
```

## Exit Codes

The system uses specific exit codes for different error types:

- `0` - Success
- `1` - General error
- `2` - CI failure
- `3` - Merge conflict
- `4` - API failure
- `5` - Retry exhausted

## Integration Points

### 1. Lefthook Hooks

Updated `lefthook.yml` to use error handling for critical operations:

```yaml
rails-tests:
  run: |
    bin/cli-error-handler --pr-number "${PR_NUMBER}" -- CI=true RAILS_ENV=test mise exec -- bin/rails test
```

### 2. PR Lifecycle Scripts

Enhanced `scripts/pr-lifecycle.sh` and `scripts/sync-branch.sh`:

```bash
# GitHub CLI operations with retry
call_github_cli() {
    bin/cli-error-handler --retry -- gh "$@"
}

# Merge operations with conflict handling  
auto_merge_base() {
    bin/cli-error-handler -- mise exec -- git merge origin/main --no-edit
}
```

### 3. Status Polling Scripts

Updated `poll-pr-status.sh` for robust GitHub operations:

```bash
# GitHub comment posting with retry
bin/cli-error-handler --retry --pr-number "${pr_number}" -- gh pr comment "${pr_number}" --body "${comment_body}"
```

## Development Guidelines

### Adding Error Handling to New Scripts

1. **For CI Operations**: Use `--pr-number` option to enable GitHub comment posting
2. **For API Operations**: Use `--retry` flag to enable exponential backoff
3. **For Merge Operations**: Basic usage will automatically detect and handle conflicts
4. **For Custom Retry Logic**: Configure `--max-retries` as needed

### Testing Error Scenarios

```bash
# Test CI failure detection
bin/cli-error-handler --pr-number 123 -- bin/rails test:failing_test

# Test merge conflict handling
bin/cli-error-handler -- git merge conflict-branch

# Test API retry logic
bin/cli-error-handler --retry -- curl -H "Authorization: token invalid" https://api.github.com/user
```

### Extending Error Classification

Add new error patterns to `TRANSIENT_ERROR_PATTERNS` in `lib/cli_error_handler.rb`:

```ruby
TRANSIENT_ERROR_PATTERNS = [
  /connection.*reset/i,
  /timeout/i,
  # Add new patterns here
  /your_custom_pattern/i
].freeze
```

## Monitoring and Observability

### Logging

All operations are logged with structured information:

```
[2024-01-15 10:30:00] INFO: Executing command: gh api repos/owner/repo
[2024-01-15 10:30:01] ERROR: Command failed with exit code 22 after 1.23s
[2024-01-15 10:30:01] WARN: Transient error detected, retrying in 1s (attempt 1/4)
[2024-01-15 10:30:02] INFO: Command succeeded after 1 retries
```

### GitHub Comments

Automatic GitHub comments provide visibility into:

- CI failures with full error context
- Retry exhaustion notifications
- Resolution guidance

### Exit Code Monitoring

Scripts can monitor specific exit codes for different error types:

```bash
bin/cli-error-handler -- some-command
case $? in
    0) echo "Success" ;;
    2) echo "CI failure - check GitHub comments" ;;
    3) echo "Merge conflict - resolve manually" ;;
    4) echo "API failure - check connectivity" ;;
    5) echo "Retries exhausted - wait and try again" ;;
esac
```

## Performance Considerations

### Retry Timing

- **Base Delay**: 1 second (configurable)
- **Backoff Multiplier**: 2.0 (exponential)
- **Maximum Delay**: 60 seconds (prevents excessive waits)
- **Maximum Retries**: 3 (balances reliability vs. speed)

### GitHub API Rate Limits

- Automatic detection of rate limit errors
- Exponential backoff helps stay within limits
- Comment posting is throttled to avoid spam

### Resource Usage

- Minimal overhead for successful operations
- Structured logging prevents excessive output
- GitHub comments only posted for actual failures

## Security Considerations

### Token Handling

- GitHub tokens are passed through environment variables
- No tokens are logged or exposed in error messages
- Error handler respects existing token security practices

### Error Information

- Sensitive information is filtered from error messages
- GitHub comments include only necessary debugging information
- Full stack traces are limited to local logs

### Command Execution

- Commands are executed through `Open3.capture3` for security
- Shell injection protection through proper argument handling
- Environment isolation through `mise exec`

## Troubleshooting

### Common Issues

1. **"CLI error handler not found"**
   ```bash
   # Ensure the script is executable
   chmod +x bin/cli-error-handler
   ```

2. **"GitHub token not available"**
   ```bash
   # Set the GitHub token
   export GITHUB_TOKEN="your_token_here"
   ```

3. **"PR number not detected"**
   ```bash
   # Explicitly provide PR number
   bin/cli-error-handler --pr-number 123 -- your-command
   ```

### Debug Mode

Enable debug logging for troubleshooting:

```bash
bin/cli-error-handler --log-level DEBUG -- your-command
```

### Manual Testing

Test specific error scenarios:

```bash
# Test basic error handling
bin/cli-error-handler -- false

# Test GitHub integration
bin/cli-error-handler --pr-number 123 --dry-run -- false

# Test retry logic
bin/cli-error-handler --retry --max-retries 2 -- curl https://httpstat.us/500
```

## Future Enhancements

### Planned Features

1. **Slack Integration**: Post critical failures to Slack channels
2. **Metrics Collection**: Collect error statistics for monitoring
3. **Custom Webhooks**: Support for custom notification endpoints
4. **Error Categorization**: More granular error classification
5. **Recovery Actions**: Automatic recovery for certain error types

### Configuration File Support

Future versions may support configuration files for team-wide settings:

```yaml
# .cli-error-handler.yml
retry:
  max_retries: 3
  base_delay: 1.0
  max_delay: 60.0

github:
  auto_detect_pr: true
  comment_on_failure: true

logging:
  level: INFO
  file: logs/cli-errors.log
```

This implementation provides comprehensive error handling that meets all the specified requirements while integrating seamlessly with the existing project infrastructure.
