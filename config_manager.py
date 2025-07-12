#!/usr/bin/env python3
"""
Configuration Manager for PR Workflow

This module handles loading and validation of .pr-workflow.yml configuration files
for repo-specific settings.

Supported configuration options:
- baseBranch: The default branch to merge PRs into
- mergeMethod: How PRs should be merged (merge, squash, rebase)
- pollInterval: How often to check for PR status updates (in seconds)
- reviewModel: Which review model to use (local-gpt, gpt-4, claude, etc.)
- autoApprove: Whether to auto-approve PRs that meet criteria
- requiredChecks: List of required status checks before merging
- notificationSettings: Settings for notifications
"""

import os
import yaml
from pathlib import Path
from typing import Dict, Any, Optional, List, Union
from dataclasses import dataclass, field
import logging


@dataclass
class NotificationSettings:
    """Configuration for notification settings"""
    slack_webhook: Optional[str] = None
    email_recipients: List[str] = field(default_factory=list)
    notify_on_approval: bool = True
    notify_on_merge: bool = True
    notify_on_failure: bool = True


@dataclass
class PRWorkflowConfig:
    """Configuration for PR workflow settings"""
    # Core settings
    base_branch: str = "main"
    merge_method: str = "squash"
    poll_interval: int = 300
    review_model: str = "local-gpt"
    
    # Advanced settings
    auto_approve: bool = False
    required_checks: List[str] = field(default_factory=list)
    max_review_attempts: int = 3
    review_timeout: int = 1800  # 30 minutes in seconds
    
    # File and path settings
    config_file_path: str = ".pr-workflow.yml"
    ignore_paths: List[str] = field(default_factory=lambda: [
        "node_modules/**",
        "vendor/**",
        "*.lock",
        "*.log"
    ])
    
    # Notification settings
    notifications: NotificationSettings = field(default_factory=NotificationSettings)
    
    # Review criteria
    min_approvals: int = 1
    allow_self_approval: bool = False
    require_review_from_codeowners: bool = False
    
    # Security settings
    allow_fork_prs: bool = True
    require_signed_commits: bool = False
    
    def __post_init__(self):
        """Validate configuration after initialization"""
        self._validate_config()
    
    def _validate_config(self):
        """Validate configuration values"""
        # Validate merge method
        valid_merge_methods = ["merge", "squash", "rebase"]
        if self.merge_method not in valid_merge_methods:
            raise ValueError(f"Invalid merge method: {self.merge_method}. Must be one of: {valid_merge_methods}")
        
        # Validate poll interval
        if self.poll_interval < 30:
            raise ValueError("Poll interval must be at least 30 seconds")
        
        # Validate review model
        valid_review_models = ["local-gpt", "gpt-4", "gpt-3.5-turbo", "claude", "gemini", "disabled"]
        if self.review_model not in valid_review_models:
            raise ValueError(f"Invalid review model: {self.review_model}. Must be one of: {valid_review_models}")
        
        # Validate timeout
        if self.review_timeout < 60:
            raise ValueError("Review timeout must be at least 60 seconds")
        
        # Validate max attempts
        if self.max_review_attempts < 1:
            raise ValueError("Max review attempts must be at least 1")
        
        # Validate min approvals
        if self.min_approvals < 0:
            raise ValueError("Min approvals cannot be negative")


class ConfigManager:
    """Manages loading and validation of PR workflow configuration"""
    
    def __init__(self, repo_path: str = "."):
        self.repo_path = Path(repo_path).resolve()
        self.logger = logging.getLogger(__name__)
        self._config: Optional[PRWorkflowConfig] = None
        self._config_file_path: Optional[Path] = None
    
    def load_config(self, config_file: Optional[str] = None) -> PRWorkflowConfig:
        """
        Load configuration from .pr-workflow.yml file
        
        Args:
            config_file: Optional path to config file. If None, searches for .pr-workflow.yml
        
        Returns:
            PRWorkflowConfig: Loaded and validated configuration
        """
        try:
            # Find config file
            config_path = self._find_config_file(config_file)
            
            if config_path and config_path.exists():
                self.logger.info(f"Loading configuration from: {config_path}")
                config_data = self._load_yaml_file(config_path)
                self._config_file_path = config_path
            else:
                self.logger.info("No configuration file found, using defaults")
                config_data = {}
            
            # Create config object with defaults and overrides
            config = self._create_config_from_data(config_data)
            
            # Cache the configuration
            self._config = config
            
            self.logger.info(f"Configuration loaded successfully: {config}")
            return config
            
        except Exception as e:
            self.logger.error(f"Failed to load configuration: {e}")
            # Return default configuration on error
            return PRWorkflowConfig()
    
    def _find_config_file(self, config_file: Optional[str] = None) -> Optional[Path]:
        """Find the configuration file in the repository"""
        if config_file:
            return Path(config_file).resolve()
        
        # Search for .pr-workflow.yml in current directory and parent directories
        current_dir = self.repo_path
        
        while current_dir != current_dir.parent:
            config_path = current_dir / ".pr-workflow.yml"
            if config_path.exists():
                return config_path
            
            # Also check for alternate names
            for alt_name in [".pr-workflow.yaml", "pr-workflow.yml", "pr-workflow.yaml"]:
                alt_path = current_dir / alt_name
                if alt_path.exists():
                    return alt_path
            
            current_dir = current_dir.parent
        
        return None
    
    def _load_yaml_file(self, file_path: Path) -> Dict[str, Any]:
        """Load and parse YAML file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
                return data or {}
        except yaml.YAMLError as e:
            raise ValueError(f"Invalid YAML in config file {file_path}: {e}")
        except Exception as e:
            raise ValueError(f"Failed to read config file {file_path}: {e}")
    
    def _create_config_from_data(self, data: Dict[str, Any]) -> PRWorkflowConfig:
        """Create configuration object from loaded data"""
        # Handle nested notification settings
        notification_data = data.get('notifications', {})
        notifications = NotificationSettings(
            slack_webhook=notification_data.get('slackWebhook'),
            email_recipients=notification_data.get('emailRecipients', []),
            notify_on_approval=notification_data.get('notifyOnApproval', True),
            notify_on_merge=notification_data.get('notifyOnMerge', True),
            notify_on_failure=notification_data.get('notifyOnFailure', True)
        )
        
        # Create main config object
        config = PRWorkflowConfig(
            base_branch=data.get('baseBranch', 'main'),
            merge_method=data.get('mergeMethod', 'squash'),
            poll_interval=data.get('pollInterval', 300),
            review_model=data.get('reviewModel', 'local-gpt'),
            auto_approve=data.get('autoApprove', False),
            required_checks=data.get('requiredChecks', []),
            max_review_attempts=data.get('maxReviewAttempts', 3),
            review_timeout=data.get('reviewTimeout', 1800),
            ignore_paths=data.get('ignorePaths', [
                "node_modules/**",
                "vendor/**",
                "*.lock",
                "*.log"
            ]),
            notifications=notifications,
            min_approvals=data.get('minApprovals', 1),
            allow_self_approval=data.get('allowSelfApproval', False),
            require_review_from_codeowners=data.get('requireReviewFromCodeowners', False),
            allow_fork_prs=data.get('allowForkPRs', True),
            require_signed_commits=data.get('requireSignedCommits', False)
        )
        
        return config
    
    def get_config(self) -> PRWorkflowConfig:
        """Get the current configuration, loading if necessary"""
        if self._config is None:
            return self.load_config()
        return self._config
    
    def reload_config(self) -> PRWorkflowConfig:
        """Force reload of configuration"""
        self._config = None
        return self.load_config()
    
    def save_config(self, config: PRWorkflowConfig, file_path: Optional[str] = None) -> None:
        """Save configuration to file"""
        if file_path:
            config_path = Path(file_path)
        elif self._config_file_path:
            config_path = self._config_file_path
        else:
            config_path = self.repo_path / ".pr-workflow.yml"
        
        # Convert config to dictionary
        config_dict = self._config_to_dict(config)
        
        # Save to YAML file
        try:
            with open(config_path, 'w', encoding='utf-8') as f:
                yaml.dump(config_dict, f, default_flow_style=False, sort_keys=False)
            
            self.logger.info(f"Configuration saved to: {config_path}")
        except Exception as e:
            self.logger.error(f"Failed to save configuration: {e}")
            raise
    
    def _config_to_dict(self, config: PRWorkflowConfig) -> Dict[str, Any]:
        """Convert configuration object to dictionary for YAML serialization"""
        return {
            'baseBranch': config.base_branch,
            'mergeMethod': config.merge_method,
            'pollInterval': config.poll_interval,
            'reviewModel': config.review_model,
            'autoApprove': config.auto_approve,
            'requiredChecks': config.required_checks,
            'maxReviewAttempts': config.max_review_attempts,
            'reviewTimeout': config.review_timeout,
            'ignorePaths': config.ignore_paths,
            'notifications': {
                'slackWebhook': config.notifications.slack_webhook,
                'emailRecipients': config.notifications.email_recipients,
                'notifyOnApproval': config.notifications.notify_on_approval,
                'notifyOnMerge': config.notifications.notify_on_merge,
                'notifyOnFailure': config.notifications.notify_on_failure
            },
            'minApprovals': config.min_approvals,
            'allowSelfApproval': config.allow_self_approval,
            'requireReviewFromCodeowners': config.require_review_from_codeowners,
            'allowForkPRs': config.allow_fork_prs,
            'requireSignedCommits': config.require_signed_commits
        }
    
    def validate_config_file(self, file_path: Optional[str] = None) -> tuple[bool, List[str]]:
        """
        Validate configuration file without loading it
        
        Returns:
            tuple: (is_valid, list_of_errors)
        """
        errors = []
        
        try:
            # Find and load config file
            config_path = self._find_config_file(file_path)
            if not config_path or not config_path.exists():
                return True, []  # No config file is valid (uses defaults)
            
            data = self._load_yaml_file(config_path)
            
            # Try to create config object (this will validate)
            try:
                self._create_config_from_data(data)
            except ValueError as e:
                errors.append(str(e))
            
            # Additional validation checks
            if 'baseBranch' in data and not isinstance(data['baseBranch'], str):
                errors.append("baseBranch must be a string")
            
            if 'pollInterval' in data and not isinstance(data['pollInterval'], int):
                errors.append("pollInterval must be an integer")
            
            if 'requiredChecks' in data and not isinstance(data['requiredChecks'], list):
                errors.append("requiredChecks must be a list")
            
            return len(errors) == 0, errors
            
        except Exception as e:
            errors.append(f"Failed to validate config file: {e}")
            return False, errors
    
    def create_example_config(self, file_path: Optional[str] = None) -> None:
        """Create an example configuration file"""
        example_config = PRWorkflowConfig(
            base_branch="main",
            merge_method="squash",
            poll_interval=300,
            review_model="local-gpt",
            auto_approve=False,
            required_checks=["ci/tests", "security/scan"],
            max_review_attempts=3,
            review_timeout=1800,
            ignore_paths=[
                "node_modules/**",
                "vendor/**",
                "*.lock",
                "*.log",
                "dist/**"
            ],
            notifications=NotificationSettings(
                slack_webhook="https://hooks.slack.com/services/...",
                email_recipients=["team@example.com"],
                notify_on_approval=True,
                notify_on_merge=True,
                notify_on_failure=True
            ),
            min_approvals=1,
            allow_self_approval=False,
            require_review_from_codeowners=True,
            allow_fork_prs=True,
            require_signed_commits=False
        )
        
        if file_path:
            config_path = Path(file_path)
        else:
            config_path = self.repo_path / ".pr-workflow.yml"
        
        # Add comments to the example
        example_yaml = f"""# PR Workflow Configuration
# This file configures the automated PR workflow for this repository

# Base branch to merge PRs into
baseBranch: {example_config.base_branch}

# How to merge PRs: merge, squash, or rebase
mergeMethod: {example_config.merge_method}

# How often to poll for PR status updates (seconds)
pollInterval: {example_config.poll_interval}

# Review model to use: local-gpt, gpt-4, claude, gemini, or disabled
reviewModel: {example_config.review_model}

# Whether to auto-approve PRs that meet all criteria
autoApprove: {str(example_config.auto_approve).lower()}

# Required status checks before merging
requiredChecks:
  - ci/tests
  - security/scan

# Maximum number of review attempts
maxReviewAttempts: {example_config.max_review_attempts}

# Review timeout in seconds
reviewTimeout: {example_config.review_timeout}

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
minApprovals: {example_config.min_approvals}

# Allow PR author to approve their own PR
allowSelfApproval: {str(example_config.allow_self_approval).lower()}

# Require review from code owners
requireReviewFromCodeowners: {str(example_config.require_review_from_codeowners).lower()}

# Allow PRs from forks
allowForkPRs: {str(example_config.allow_fork_prs).lower()}

# Require signed commits
requireSignedCommits: {str(example_config.require_signed_commits).lower()}
"""
        
        try:
            with open(config_path, 'w', encoding='utf-8') as f:
                f.write(example_yaml)
            
            self.logger.info(f"Example configuration created at: {config_path}")
        except Exception as e:
            self.logger.error(f"Failed to create example config: {e}")
            raise


def main():
    """CLI interface for configuration management"""
    import argparse
    
    parser = argparse.ArgumentParser(description="PR Workflow Configuration Manager")
    parser.add_argument("--validate", action="store_true", help="Validate configuration file")
    parser.add_argument("--create-example", action="store_true", help="Create example configuration file")
    parser.add_argument("--config-file", help="Path to configuration file")
    parser.add_argument("--repo-path", default=".", help="Repository path")
    
    args = parser.parse_args()
    
    # Set up logging
    logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
    
    config_manager = ConfigManager(args.repo_path)
    
    if args.create_example:
        config_manager.create_example_config(args.config_file)
        print("✅ Example configuration file created")
    
    elif args.validate:
        is_valid, errors = config_manager.validate_config_file(args.config_file)
        if is_valid:
            print("✅ Configuration is valid")
        else:
            print("❌ Configuration validation failed:")
            for error in errors:
                print(f"  • {error}")
    
    else:
        # Load and display configuration
        config = config_manager.load_config(args.config_file)
        print("📋 Current configuration:")
        print(f"  Base Branch: {config.base_branch}")
        print(f"  Merge Method: {config.merge_method}")
        print(f"  Poll Interval: {config.poll_interval}s")
        print(f"  Review Model: {config.review_model}")
        print(f"  Auto Approve: {config.auto_approve}")
        print(f"  Required Checks: {config.required_checks}")
        print(f"  Min Approvals: {config.min_approvals}")


if __name__ == "__main__":
    main()
