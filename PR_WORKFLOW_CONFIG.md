# PR Workflow Configuration

This document describes the configuration system for automated PR workflows using `.pr-workflow.yml` files.

## Overview

The PR workflow configuration system allows you to customize automated code review behavior on a per-repository basis. Configuration is loaded at runtime and validated to ensure correct operation.

## Configuration File

Create a `.pr-workflow.yml` file in your repository root with the following structure:

```yaml
# PR Workflow Configuration
# This file configures the automated PR workflow for this repository

# Base branch to merge PRs into
baseBranch: main

# How to merge PRs: merge, squash, or rebase
mergeMethod: squash

# How often to poll for PR status updates (seconds)
pollInterval: 300

# Review model to use: local-gpt, gpt-4, claude, gemini, or disabled
reviewModel: local-gpt

# Whether to auto-approve PRs that meet all criteria
autoApprove: false

# Required status checks before merging
requiredChecks:
  - ci/tests
  - security/scan

# Maximum number of review attempts
maxReviewAttempts: 3

# Review timeout in seconds
reviewTimeout: 1800

# Paths to ignore during review
ignorePaths:
  - node_modules/**
  - vendor/**
  - "*.lock"
  - "*.log"
  - dist/**

# Notification settings
notifications:
  slackWebhook: "https://hooks.slack.com/services/..."
  emailRecipients:
    - team@example.com
  notifyOnApproval: true
  notifyOnMerge: true
  notifyOnFailure: true

# Minimum number of approvals required
minApprovals: 1

# Allow PR author to approve their own PR
allowSelfApproval: false

# Require review from code owners
requireReviewFromCodeowners: true

# Allow PRs from forks
allowForkPRs: true

# Require signed commits
requireSignedCommits: false
```

## Configuration Options

### Core Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `baseBranch` | string | `"main"` | Default branch to merge PRs into |
| `mergeMethod` | string | `"squash"` | Merge method: `merge`, `squash`, or `rebase` |
| `pollInterval` | integer | `300` | Poll interval in seconds (minimum 30) |
| `reviewModel` | string | `"local-gpt"` | Review model: `local-gpt`, `gpt-4`, `claude`, `gemini`, or `disabled` |

### Review Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `autoApprove` | boolean | `false` | Whether to auto-approve PRs that meet criteria |
| `requiredChecks` | array | `[]` | List of required status checks |
| `maxReviewAttempts` | integer | `3` | Maximum number of review attempts |
| `reviewTimeout` | integer | `1800` | Review timeout in seconds (minimum 60) |
| `ignorePaths` | array | See defaults | File patterns to ignore during review |

### Approval Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `minApprovals` | integer | `1` | Minimum number of approvals required |
| `allowSelfApproval` | boolean | `false` | Allow PR author to approve their own PR |
| `requireReviewFromCodeowners` | boolean | `false` | Require review from code owners |

### Security Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `allowForkPRs` | boolean | `true` | Allow PRs from forks |
| `requireSignedCommits` | boolean | `false` | Require signed commits |

### Notification Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `notifications.slackWebhook` | string | `null` | Slack webhook URL |
| `notifications.emailRecipients` | array | `[]` | Email addresses for notifications |
| `notifications.notifyOnApproval` | boolean | `true` | Send notifications on approval |
| `notifications.notifyOnMerge` | boolean | `true` | Send notifications on merge |
| `notifications.notifyOnFailure` | boolean | `true` | Send notifications on failure |

## Usage

### Command Line Interface

#### Create Example Configuration
```bash
python automated_code_review.py --create-config
```

#### Validate Configuration
```bash
python automated_code_review.py --validate-config
```

#### Use Custom Configuration File
```bash
python automated_code_review.py --owner myorg --repo myrepo --pr 123 --config-file custom-config.yml
```

### Python API

```python
from config_manager import ConfigManager, PRWorkflowConfig

# Load configuration
config_manager = ConfigManager()
config = config_manager.load_config()

# Access configuration values
print(f"Base branch: {config.base_branch}")
print(f"Merge method: {config.merge_method}")
print(f"Review model: {config.review_model}")

# Check if auto-approval is enabled
if config.auto_approve:
    print("Auto-approval is enabled")

# Use ignore paths for file filtering
for file_path in changed_files:
    if not any(fnmatch.fnmatch(file_path, pattern) for pattern in config.ignore_paths):
        # Process file
        pass
```

## Configuration Discovery

The system searches for configuration files in the following order:

1. Specified file path (if provided)
2. `.pr-workflow.yml` in current directory
3. `.pr-workflow.yaml` in current directory
4. `pr-workflow.yml` in current directory
5. `pr-workflow.yaml` in current directory
6. Search parent directories for any of the above

If no configuration file is found, default values are used.

## Validation

Configuration files are automatically validated when loaded. Common validation errors include:

- Invalid merge method (must be `merge`, `squash`, or `rebase`)
- Poll interval too low (minimum 30 seconds)
- Invalid review model
- Review timeout too low (minimum 60 seconds)
- Invalid data types for configuration values

## Integration with Automated Code Review

The configuration system is fully integrated with the automated code review system:

```python
from automated_code_review import CodeReviewAutomator

# Initialize with configuration
automator = CodeReviewAutomator(
    owner="myorg",
    repo="myrepo", 
    pr_number=123,
    config_file=".pr-workflow.yml"  # Optional
)

# Configuration is automatically loaded and applied
automator.run_automated_review()
```

## Examples

### Minimal Configuration
```yaml
baseBranch: main
mergeMethod: squash
reviewModel: local-gpt
```

### Production Configuration
```yaml
baseBranch: main
mergeMethod: squash
pollInterval: 300
reviewModel: gpt-4
autoApprove: false
requiredChecks:
  - ci/build
  - ci/test
  - security/scan
  - code-quality/lint
maxReviewAttempts: 3
reviewTimeout: 3600
ignorePaths:
  - node_modules/**
  - vendor/**
  - dist/**
  - "*.lock"
  - "*.log"
  - "*.tmp"
notifications:
  slackWebhook: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  emailRecipients:
    - devteam@company.com
    - security@company.com
  notifyOnApproval: true
  notifyOnMerge: true
  notifyOnFailure: true
minApprovals: 2
allowSelfApproval: false
requireReviewFromCodeowners: true
allowForkPRs: false
requireSignedCommits: true
```

### Development Configuration
```yaml
baseBranch: develop
mergeMethod: rebase
pollInterval: 600
reviewModel: local-gpt
autoApprove: true
requiredChecks:
  - ci/test
maxReviewAttempts: 1
reviewTimeout: 900
ignorePaths:
  - "*.tmp"
  - "*.log"
  - node_modules/**
notifications:
  slackWebhook: "https://hooks.slack.com/services/DEV/WEBHOOK/URL"
  notifyOnFailure: true
minApprovals: 1
allowSelfApproval: true
requireReviewFromCodeowners: false
allowForkPRs: true
requireSignedCommits: false
```

## Testing

Run the configuration test suite:

```bash
python test_pr_workflow_config.py
```

This will test:
- Default configuration loading
- Custom configuration loading
- Configuration validation
- File discovery
- Integration with the review system

## Troubleshooting

### Configuration Not Found
If the configuration file isn't being found:
1. Check the file name (should be `.pr-workflow.yml`)
2. Verify the file is in the repository root or a parent directory
3. Check file permissions

### Validation Errors
If configuration validation fails:
1. Check the YAML syntax
2. Verify all values are the correct type
3. Ensure required fields are present
4. Check that values are within valid ranges

### Review Model Issues
If the review model isn't working:
1. For `local-gpt`: Ensure Ollama or LocalAI is running
2. For cloud models: Verify API keys are configured
3. Use `disabled` to skip automated review

## Advanced Features

### Custom Notification Handlers
Extend the notification system by implementing custom handlers:

```python
class CustomNotificationHandler:
    def __init__(self, config):
        self.config = config
    
    def notify(self, event, data):
        # Custom notification logic
        pass
```

### Dynamic Configuration
Load configuration dynamically based on branch or environment:

```python
def get_config_for_branch(branch):
    if branch.startswith('release/'):
        return 'config/release.yml'
    elif branch == 'main':
        return 'config/production.yml'
    else:
        return 'config/development.yml'

config_file = get_config_for_branch(current_branch)
config = ConfigManager().load_config(config_file)
```

## Migration

### From Hardcoded Settings
If you're migrating from hardcoded settings:

1. Create a `.pr-workflow.yml` file with your current settings
2. Remove hardcoded values from your scripts
3. Update scripts to use `ConfigManager`
4. Test with `--validate-config`

### Version Compatibility
The configuration system is backward compatible. New options will have sensible defaults, and old configuration files will continue to work.

## Contributing

When adding new configuration options:

1. Add the field to the `PRWorkflowConfig` dataclass
2. Update validation in `_validate_config()`
3. Add default handling in `_create_config_from_data()`
4. Update this documentation
5. Add tests in `test_pr_workflow_config.py`
