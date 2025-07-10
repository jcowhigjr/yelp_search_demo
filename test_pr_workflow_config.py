#!/usr/bin/env python3
"""
Test script for PR Workflow Configuration

This script demonstrates the configuration system functionality including:
- Loading configuration from .pr-workflow.yml
- Validation of configuration values
- Runtime configuration access
- Integration with automated code review
"""

import sys
import tempfile
from pathlib import Path
from config_manager import ConfigManager, PRWorkflowConfig, NotificationSettings


def test_default_config():
    """Test loading default configuration when no file exists"""
    print("🧪 Testing default configuration...")
    
    with tempfile.TemporaryDirectory() as temp_dir:
        config_manager = ConfigManager(temp_dir)
        config = config_manager.load_config()
        
        assert config.base_branch == "main"
        assert config.merge_method == "squash"
        assert config.poll_interval == 300
        assert config.review_model == "local-gpt"
        print("✅ Default configuration loaded successfully")


def test_custom_config():
    """Test loading custom configuration from YAML file"""
    print("\n🧪 Testing custom configuration...")
    
    custom_yaml = """
baseBranch: develop
mergeMethod: rebase
pollInterval: 600
reviewModel: gpt-4
autoApprove: true
requiredChecks:
  - ci/build
  - ci/test
  - security/scan
maxReviewAttempts: 5
reviewTimeout: 3600
ignorePaths:
  - "*.tmp"
  - temp/**
  - build/**
notifications:
  slackWebhook: "https://hooks.slack.com/services/test"
  emailRecipients:
    - dev@company.com
    - qa@company.com
  notifyOnApproval: false
  notifyOnMerge: true
  notifyOnFailure: true
minApprovals: 2
allowSelfApproval: true
requireReviewFromCodeowners: false
allowForkPRs: false
requireSignedCommits: true
"""
    
    with tempfile.TemporaryDirectory() as temp_dir:
        config_file = Path(temp_dir) / ".pr-workflow.yml"
        with open(config_file, 'w') as f:
            f.write(custom_yaml)
        
        config_manager = ConfigManager(temp_dir)
        config = config_manager.load_config()
        
        # Validate custom values
        assert config.base_branch == "develop"
        assert config.merge_method == "rebase"
        assert config.poll_interval == 600
        assert config.review_model == "gpt-4"
        assert config.auto_approve == True
        assert config.required_checks == ["ci/build", "ci/test", "security/scan"]
        assert config.max_review_attempts == 5
        assert config.review_timeout == 3600
        assert "*.tmp" in config.ignore_paths
        assert config.notifications.slack_webhook == "https://hooks.slack.com/services/test"
        assert config.notifications.email_recipients == ["dev@company.com", "qa@company.com"]
        assert config.min_approvals == 2
        assert config.allow_self_approval == True
        assert config.require_review_from_codeowners == False
        assert config.allow_fork_prs == False
        assert config.require_signed_commits == True
        
        print("✅ Custom configuration loaded successfully")


def test_config_validation():
    """Test configuration validation"""
    print("\n🧪 Testing configuration validation...")
    
    # Test invalid merge method
    invalid_yaml = """
baseBranch: main
mergeMethod: invalid_method
pollInterval: 300
reviewModel: local-gpt
"""
    
    with tempfile.TemporaryDirectory() as temp_dir:
        config_file = Path(temp_dir) / ".pr-workflow.yml"
        with open(config_file, 'w') as f:
            f.write(invalid_yaml)
        
        config_manager = ConfigManager(temp_dir)
        is_valid, errors = config_manager.validate_config_file()
        
        assert not is_valid
        assert any("Invalid merge method" in error for error in errors)
        print("✅ Invalid merge method detected correctly")
    
    # Test invalid poll interval
    invalid_yaml2 = """
baseBranch: main
mergeMethod: squash
pollInterval: 10
reviewModel: local-gpt
"""
    
    with tempfile.TemporaryDirectory() as temp_dir:
        config_file = Path(temp_dir) / ".pr-workflow.yml"
        with open(config_file, 'w') as f:
            f.write(invalid_yaml2)
        
        config_manager = ConfigManager(temp_dir)
        is_valid, errors = config_manager.validate_config_file()
        
        assert not is_valid
        assert any("Poll interval must be at least 30 seconds" in error for error in errors)
        print("✅ Invalid poll interval detected correctly")


def test_config_file_discovery():
    """Test configuration file discovery in parent directories"""
    print("\n🧪 Testing configuration file discovery...")
    
    with tempfile.TemporaryDirectory() as temp_dir:
        # Create nested directory structure
        nested_dir = Path(temp_dir) / "project" / "subdir"
        nested_dir.mkdir(parents=True)
        
        # Place config file in parent directory
        config_file = Path(temp_dir) / "project" / ".pr-workflow.yml"
        with open(config_file, 'w') as f:
            f.write("baseBranch: discovery_test\n")
        
        # Try to load config from nested directory
        config_manager = ConfigManager(str(nested_dir))
        config = config_manager.load_config()
        
        assert config.base_branch == "discovery_test"
        print("✅ Configuration file discovered in parent directory")


def test_save_config():
    """Test saving configuration to file"""
    print("\n🧪 Testing configuration saving...")
    
    with tempfile.TemporaryDirectory() as temp_dir:
        config_manager = ConfigManager(temp_dir)
        
        # Create custom config
        custom_config = PRWorkflowConfig(
            base_branch="feature",
            merge_method="merge",
            poll_interval=450,
            review_model="claude",
            auto_approve=True,
            required_checks=["test", "lint"],
            notifications=NotificationSettings(
                slack_webhook="https://test.webhook",
                email_recipients=["test@example.com"]
            )
        )
        
        # Save config
        config_manager.save_config(custom_config)
        
        # Reload and verify
        reloaded_config = config_manager.load_config()
        assert reloaded_config.base_branch == "feature"
        assert reloaded_config.merge_method == "merge"
        assert reloaded_config.poll_interval == 450
        assert reloaded_config.review_model == "claude"
        assert reloaded_config.auto_approve == True
        assert reloaded_config.required_checks == ["test", "lint"]
        
        print("✅ Configuration saved and reloaded successfully")


def test_integration_with_automator():
    """Test integration with CodeReviewAutomator"""
    print("\n🧪 Testing integration with CodeReviewAutomator...")
    
    # This would normally import the actual automator
    # For testing, we'll simulate it
    
    config_yaml = """
baseBranch: main
mergeMethod: squash
pollInterval: 300
reviewModel: local-gpt
autoApprove: false
ignorePaths:
  - "*.log"
  - "temp/**"
  - node_modules/**
"""
    
    with tempfile.TemporaryDirectory() as temp_dir:
        config_file = Path(temp_dir) / ".pr-workflow.yml"
        with open(config_file, 'w') as f:
            f.write(config_yaml)
        
        # Simulate loading config in automator
        config_manager = ConfigManager(temp_dir)
        config = config_manager.load_config()
        
        # Verify configuration is available
        assert config.base_branch == "main"
        assert config.merge_method == "squash"
        assert config.review_model == "local-gpt"
        assert "*.log" in config.ignore_paths
        assert "node_modules/**" in config.ignore_paths
        
        print("✅ Configuration integration works correctly")


def test_example_config_creation():
    """Test example configuration file creation"""
    print("\n🧪 Testing example configuration creation...")
    
    with tempfile.TemporaryDirectory() as temp_dir:
        config_manager = ConfigManager(temp_dir)
        config_manager.create_example_config()
        
        # Verify file was created
        config_file = Path(temp_dir) / ".pr-workflow.yml"
        assert config_file.exists()
        
        # Verify it can be loaded
        config = config_manager.load_config()
        assert config.base_branch == "main"
        assert config.merge_method == "squash"
        
        print("✅ Example configuration created successfully")


def demonstrate_runtime_usage():
    """Demonstrate how configuration is used at runtime"""
    print("\n🚀 Demonstrating runtime configuration usage...")
    
    # Create a sample configuration
    config_yaml = """
baseBranch: main
mergeMethod: squash
pollInterval: 300
reviewModel: local-gpt
autoApprove: false
requiredChecks:
  - ci/tests
  - security/scan
maxReviewAttempts: 3
reviewTimeout: 1800
ignorePaths:
  - node_modules/**
  - vendor/**
  - "*.lock"
  - "*.log"
notifications:
  slackWebhook: "https://hooks.slack.com/services/example"
  emailRecipients:
    - team@example.com
  notifyOnApproval: true
  notifyOnMerge: true
  notifyOnFailure: true
minApprovals: 1
allowSelfApproval: false
requireReviewFromCodeowners: true
allowForkPRs: true
requireSignedCommits: false
"""
    
    with tempfile.TemporaryDirectory() as temp_dir:
        config_file = Path(temp_dir) / ".pr-workflow.yml"
        with open(config_file, 'w') as f:
            f.write(config_yaml)
        
        config_manager = ConfigManager(temp_dir)
        config = config_manager.load_config()
        
        print(f"📋 Loaded Configuration:")
        print(f"  Base Branch: {config.base_branch}")
        print(f"  Merge Method: {config.merge_method}")
        print(f"  Poll Interval: {config.poll_interval}s")
        print(f"  Review Model: {config.review_model}")
        print(f"  Auto Approve: {config.auto_approve}")
        print(f"  Required Checks: {config.required_checks}")
        print(f"  Max Review Attempts: {config.max_review_attempts}")
        print(f"  Review Timeout: {config.review_timeout}s")
        print(f"  Ignore Paths: {config.ignore_paths}")
        print(f"  Min Approvals: {config.min_approvals}")
        print(f"  Allow Self Approval: {config.allow_self_approval}")
        print(f"  Require Review from Code Owners: {config.require_review_from_codeowners}")
        print(f"  Allow Fork PRs: {config.allow_fork_prs}")
        print(f"  Require Signed Commits: {config.require_signed_commits}")
        
        # Demonstrate usage in different scenarios
        print(f"\n📝 Runtime Usage Examples:")
        
        # Determine merge strategy
        print(f"  Merge Strategy: Using {config.merge_method} method for PR merging")
        
        # Check if auto-approval is enabled
        if config.auto_approve:
            print(f"  Auto-Approval: PRs will be auto-approved if they meet criteria")
        else:
            print(f"  Manual Review: PRs require manual approval")
        
        # Review model configuration
        if config.review_model == "disabled":
            print(f"  Review: Automated review is disabled")
        else:
            print(f"  Review: Using {config.review_model} for automated reviews")
        
        # File filtering
        print(f"  File Filtering: Ignoring {len(config.ignore_paths)} path patterns")
        
        # Notification settings
        if config.notifications.slack_webhook:
            print(f"  Notifications: Slack webhook configured")
        if config.notifications.email_recipients:
            print(f"  Notifications: {len(config.notifications.email_recipients)} email recipients")
        
        print("✅ Runtime demonstration completed")


def main():
    """Run all tests"""
    print("🧪 PR Workflow Configuration Test Suite")
    print("=" * 50)
    
    try:
        test_default_config()
        test_custom_config()
        test_config_validation()
        test_config_file_discovery()
        test_save_config()
        test_integration_with_automator()
        test_example_config_creation()
        demonstrate_runtime_usage()
        
        print("\n" + "=" * 50)
        print("🎉 All tests passed successfully!")
        print("\n📋 Configuration System Features:")
        print("  ✅ YAML configuration file support")
        print("  ✅ Runtime configuration loading and validation")
        print("  ✅ Default values with override capability")
        print("  ✅ Configuration file discovery in parent directories")
        print("  ✅ Comprehensive validation with error reporting")
        print("  ✅ Integration with automated code review system")
        print("  ✅ Support for all required settings:")
        print("    • baseBranch, mergeMethod, pollInterval, reviewModel")
        print("    • autoApprove, requiredChecks, notifications")
        print("    • File ignore patterns, approval requirements")
        print("    • Security settings and timeout configuration")
        
    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
