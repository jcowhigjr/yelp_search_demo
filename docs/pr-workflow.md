# PR Workflow Guide

This guide covers the complete pull request workflow setup and usage, including lefthook configuration, MCP Docker integration, and troubleshooting common issues.

## Table of Contents

- [Setup Steps](#setup-steps)
- [Configuration File Schema](#configuration-file-schema)
- [CLI Command Reference](#cli-command-reference)
- [Troubleshooting Common Errors](#troubleshooting-common-errors)

## Setup Steps

### 1. Lefthook Setup

Lefthook is used to enforce coding standards and run automated checks before commits and pushes.

#### Installation

```bash
# Install lefthook globally
npm install -g lefthook

# Or using Go
go install github.com/evilmartians/lefthook@latest

# Or using Homebrew (macOS)
brew install lefthook
```

#### Initialize Lefthook

```bash
# Initialize lefthook in your project
lefthook install

# This creates/updates .lefthook.yml configuration
```

#### Basic Lefthook Configuration

Create or update `.lefthook.yml` in your project root:

```yaml
# .lefthook.yml
pre-commit:
  parallel: true
  commands:
    linter:
      glob: "*.{js,ts,rb,py}"
      run: mise exec -- make lint
    formatter:
      glob: "*.{js,ts,rb,py}"
      run: mise exec -- make format
    tests:
      glob: "*.{js,ts,rb,py}"
      run: mise exec -- make test

pre-push:
  parallel: false
  commands:
    security-check:
      run: mise exec -- make security-check
    full-test-suite:
      run: mise exec -- make test-full
```

### 2. MCP Docker Setup

MCP (Model Context Protocol) Docker provides additional tooling and services for the development workflow.

#### Prerequisites

- Docker installed and running
- Docker Compose (usually included with Docker Desktop)

#### Installation

```bash
# Clone or ensure you have the MCP Docker configuration
# This should be part of your project setup

# Start MCP Docker services
docker-compose up -d

# Verify services are running
docker-compose ps
```

#### MCP Docker Configuration

Create `docker-compose.yml` for MCP services:

```yaml
# docker-compose.yml
version: '3.8'

services:
  mcp-gateway:
    image: mcp-gateway:latest
    ports:
      - "8080:8080"
    environment:
      - MCP_ENV=development
      - MCP_LOG_LEVEL=info
    volumes:
      - ./config:/app/config
      - ./logs:/app/logs

  mcp-tools:
    image: mcp-tools:latest
    depends_on:
      - mcp-gateway
    environment:
      - MCP_GATEWAY_URL=http://mcp-gateway:8080
    volumes:
      - .:/workspace
```

#### Environment Setup

Create `.env` file for MCP configuration:

```bash
# .env
MCP_DOCKER_ENV=development
MCP_LOG_LEVEL=info
MCP_GATEWAY_PORT=8080
MCP_WORKSPACE_PATH=/workspace
```

### 3. Integration Setup

#### Make Commands Integration

Ensure your `Makefile` includes the necessary targets:

```makefile
# Makefile
.PHONY: lint format test security-check test-full

lint:
	@echo "Running linter..."
	# Add your linting commands here

format:
	@echo "Running formatter..."
	# Add your formatting commands here

test:
	@echo "Running tests..."
	# Add your test commands here

security-check:
	@echo "Running security checks..."
	# Add your security check commands here

test-full:
	@echo "Running full test suite..."
	# Add your comprehensive test commands here
```

#### Git Configuration

Configure Git to work with lefthook:

```bash
# Ensure Git hooks are executable
chmod +x .git/hooks/*

# Verify lefthook is working
lefthook run pre-commit
```

## Configuration File Schema

### Lefthook Configuration Schema

The `.lefthook.yml` file follows this schema:

```yaml
# Global settings
colors: true           # Enable colored output
no_tty: false         # Disable TTY mode
source_dir: .lefthook # Custom hooks directory
source_dir_local: .lefthook-local

# Pre-commit hooks
pre-commit:
  parallel: true|false    # Run commands in parallel
  piped: true|false      # Pipe output between commands
  follow: true|false     # Follow file moves
  exclude_tags:          # Exclude specific tags
    - tag1
    - tag2
  commands:
    command-name:
      glob: "*.{ext}"    # File patterns to match
      run: "command"     # Command to execute
      tags:              # Tags for this command
        - tag1
      exclude:           # Exclude patterns
        - "*.min.js"
      root: "path/"      # Root directory for command
      skip:              # Skip conditions
        - merge
        - rebase
      only:              # Only run on specific actions
        - commit
      env:               # Environment variables
        VAR: value
      fail_text: "Error message"  # Custom failure message
      interactive: true|false     # Interactive mode
      use_stdin: true|false       # Use stdin
      priority: 1                 # Execution priority

# Pre-push hooks
pre-push:
  # Same structure as pre-commit
  
# Post-commit hooks
post-commit:
  # Same structure as pre-commit
  
# Other supported hooks
commit-msg:
  # For commit message validation
post-checkout:
  # After checkout actions
pre-rebase:
  # Before rebase actions
```

### MCP Docker Configuration Schema

#### docker-compose.yml Schema

```yaml
version: '3.8'

services:
  service-name:
    image: string              # Docker image
    build:                     # Build configuration
      context: string          # Build context
      dockerfile: string       # Dockerfile path
    ports:                     # Port mappings
      - "host:container"
    environment:               # Environment variables
      - KEY=value
    volumes:                   # Volume mounts
      - host:container
    depends_on:               # Service dependencies
      - service-name
    networks:                 # Network configuration
      - network-name
    restart: always|unless-stopped|on-failure
    healthcheck:              # Health check configuration
      test: ["CMD", "command"]
      interval: 30s
      timeout: 10s
      retries: 3
```

#### Environment Variables Schema

```bash
# .env file structure
MCP_DOCKER_ENV=development|staging|production
MCP_LOG_LEVEL=debug|info|warn|error
MCP_GATEWAY_PORT=integer
MCP_WORKSPACE_PATH=string
MCP_CONFIG_PATH=string
MCP_ENABLE_FEATURES=comma,separated,list
```

### PR Workflow Configuration Schema

Based on the existing `.pr-workflow.yml` file:

```yaml
# .pr-workflow.yml
pr_workflow:
  # Branch protection settings
  branch_protection:
    enforce_admins: true|false
    required_status_checks:
      strict: true|false
      contexts:
        - "ci/test"
        - "ci/lint"
    required_pull_request_reviews:
      required_approving_review_count: integer
      dismiss_stale_reviews: true|false
      require_code_owner_reviews: true|false
    restrictions:
      users: []
      teams: []
      apps: []

  # Automated checks
  automated_checks:
    enable_auto_merge: true|false
    require_ci_pass: true|false
    require_reviews: true|false
    review_assignment:
      enabled: true|false
      reviewers:
        - username1
        - username2
      team_reviewers:
        - team1
        - team2

  # CI/CD Integration
  ci_cd:
    trigger_on:
      - pull_request
      - push
    environments:
      - name: staging
        auto_deploy: true|false
      - name: production
        auto_deploy: false
        require_approval: true

  # Notifications
  notifications:
    slack:
      enabled: true|false
      webhook_url: string
      channels:
        - "#development"
        - "#notifications"
    email:
      enabled: true|false
      recipients:
        - email@example.com
```

## CLI Command Reference

### Lefthook Commands

#### Basic Commands

```bash
# Install lefthook in current repository
lefthook install

# Uninstall lefthook
lefthook uninstall

# Run specific hook
lefthook run <hook-name>
lefthook run pre-commit
lefthook run pre-push

# Run specific command from hook
lefthook run pre-commit --commands linter

# Skip specific commands
lefthook run pre-commit --exclude-tags slow

# Version information
lefthook version

# Help
lefthook help
```

#### Advanced Commands

```bash
# Add hook
lefthook add pre-commit

# Dump configuration
lefthook dump

# Self-update
lefthook self-update

# Run with custom config
lefthook --config custom.yml run pre-commit
```

### MCP Docker Commands

#### Docker Compose Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs
docker-compose logs -f service-name

# Check service status
docker-compose ps

# Pull latest images
docker-compose pull

# Rebuild services
docker-compose up --build -d
```

#### MCP-Specific Commands

```bash
# Access MCP tools container
docker-compose exec mcp-tools bash

# Run MCP command
docker-compose exec mcp-tools mcp-command

# Check MCP gateway health
curl http://localhost:8080/health

# View MCP configuration
docker-compose exec mcp-gateway cat /app/config/config.yml
```

### Make Commands

```bash
# Run linting
make lint

# Run formatting
make format

# Run tests
make test

# Run security checks
make security-check

# Run full test suite
make test-full

# Combined workflow
make lint format test
```

### Git Commands (with lefthook)

```bash
# Normal git operations trigger lefthook automatically
git add .
git commit -m "message"  # Triggers pre-commit hooks
git push                 # Triggers pre-push hooks

# Skip hooks (use sparingly - never recommended per user preferences)
# git commit -m "message" --no-verify
# git push --no-verify

# Manual hook execution
git commit -m "message" && lefthook run post-commit
```

### PR Workflow Commands

```bash
# Run automated code review
python automated_code_review.py

# Check PR status
./poll-pr-status.sh

# Run PR workflow configuration check
python test_pr_workflow_config.py

# Review PR manually
./review_pr.sh <pr-number>
```

## Troubleshooting Common Errors

### Lefthook Issues

#### 1. "lefthook: command not found"

**Problem**: Lefthook is not installed or not in PATH.

**Solution**:
```bash
# Check if lefthook is installed
which lefthook

# Install if missing
npm install -g lefthook
# or
go install github.com/evilmartians/lefthook@latest

# Add to PATH if needed
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
source ~/.bashrc
```

#### 2. "Hook failed with exit code 1"

**Problem**: One or more commands in the hook failed.

**Solution**:
```bash
# Run hook manually to see detailed error
lefthook run pre-commit

# Check specific command
lefthook run pre-commit --commands linter

# Debug with verbose output
lefthook -v run pre-commit
```

#### 3. "Permission denied" errors

**Problem**: Git hooks don't have execute permissions.

**Solution**:
```bash
# Make hooks executable
chmod +x .git/hooks/*

# Reinstall lefthook
lefthook uninstall
lefthook install
```

#### 4. "File not found" or glob pattern issues

**Problem**: Glob patterns not matching files correctly.

**Solution**:
```yaml
# Fix glob patterns in .lefthook.yml
pre-commit:
  commands:
    linter:
      # Instead of: glob: "*.js"
      glob: "**/*.js"  # Match recursively
      # or
      glob: "{src,test}/**/*.js"  # Match specific directories
```

### MCP Docker Issues

#### 1. "Port already in use"

**Problem**: MCP services can't bind to ports.

**Solution**:
```bash
# Check what's using the port
lsof -i :8080

# Kill process using port
kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "8081:8080"  # Use different host port
```

#### 2. "Service unhealthy" or connection refused

**Problem**: MCP services not starting properly.

**Solution**:
```bash
# Check service logs
docker-compose logs mcp-gateway

# Restart specific service
docker-compose restart mcp-gateway

# Check service health
docker-compose exec mcp-gateway curl http://localhost:8080/health
```

#### 3. "Volume mount failed"

**Problem**: Docker can't mount volumes.

**Solution**:
```bash
# Check permissions
ls -la /path/to/volume

# Fix permissions
chmod 755 /path/to/volume
chown -R $(id -u):$(id -g) /path/to/volume

# Check Docker daemon is running
docker info
```

#### 4. "Image not found"

**Problem**: MCP Docker images are missing.

**Solution**:
```bash
# Pull images manually
docker-compose pull

# Build images if using local builds
docker-compose build

# Check available images
docker images | grep mcp
```

### Make Command Issues

#### 1. "make: command not found"

**Problem**: Make is not installed.

**Solution**:
```bash
# Install make (Ubuntu/Debian)
sudo apt-get install make

# Install make (macOS)
xcode-select --install
# or
brew install make

# Install make (CentOS/RHEL)
sudo yum install make
```

#### 2. "No rule to make target"

**Problem**: Make target doesn't exist in Makefile.

**Solution**:
```bash
# List available targets
make help
# or
grep "^[a-zA-Z]" Makefile

# Check Makefile exists
ls -la Makefile
```

#### 3. "Command failed with exit code"

**Problem**: Make command failed to execute.

**Solution**:
```bash
# Run with verbose output
make -n target-name  # Dry run
make -d target-name  # Debug mode

# Check individual commands
make lint
make format
make test
```

### Git Integration Issues

#### 1. "Hook was ignored because it's not set as executable"

**Problem**: Git hooks don't have execute permissions.

**Solution**:
```bash
# Make hooks executable
chmod +x .git/hooks/*

# Reinstall lefthook
lefthook install
```

#### 2. "Unable to run hook"

**Problem**: Hook script has issues.

**Solution**:
```bash
# Check hook content
cat .git/hooks/pre-commit

# Test hook manually
.git/hooks/pre-commit

# Regenerate hooks
lefthook uninstall
lefthook install
```

#### 3. "Hook timeout"

**Problem**: Hook takes too long to execute.

**Solution**:
```yaml
# Increase timeout in .lefthook.yml
pre-commit:
  commands:
    slow-command:
      run: "long-running-command"
      timeout: 300  # 5 minutes
```

### PR Workflow Issues

#### 1. "Automated review script failed"

**Problem**: Python automated review script encounters errors.

**Solution**:
```bash
# Check Python dependencies
pip install -r requirements.txt

# Run with debug output
python automated_code_review.py --debug

# Check configuration
python test_pr_workflow_config.py
```

#### 2. "PR polling script timeout"

**Problem**: PR status polling takes too long.

**Solution**:
```bash
# Check GitHub API rate limits
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/rate_limit

# Increase timeout in poll-pr-status.sh
TIMEOUT=300  # 5 minutes
```

#### 3. "Configuration validation failed"

**Problem**: PR workflow configuration has errors.

**Solution**:
```bash
# Validate configuration
python config_manager.py validate

# Check configuration file exists
ls -la .pr-workflow.yml

# Fix YAML syntax errors
yamllint .pr-workflow.yml
```

### General Debugging Tips

#### 1. Enable Verbose Logging

```bash
# Lefthook verbose mode
lefthook -v run pre-commit

# Docker compose verbose mode
docker-compose --verbose up

# Make verbose mode
make -d target-name
```

#### 2. Check Environment Variables

```bash
# Print all environment variables
printenv

# Check specific variables
echo $MCP_DOCKER_ENV
echo $PATH
echo $GITHUB_TOKEN
```

#### 3. Verify File Permissions

```bash
# Check file permissions
ls -la .lefthook.yml
ls -la Makefile
ls -la .git/hooks/

# Fix permissions if needed
chmod 644 .lefthook.yml
chmod 755 .git/hooks/*
```

#### 4. Test Components Individually

```bash
# Test lefthook configuration
lefthook run pre-commit --dry-run

# Test MCP services
curl http://localhost:8080/health

# Test make commands
make lint
make test

# Test PR workflow scripts
python automated_code_review.py --dry-run
```

## Best Practices

### 1. Configuration Management

- Keep `.lefthook.yml` in version control
- Use environment variables for sensitive configuration
- Document any custom setup steps in project README

### 2. Hook Performance

- Use `parallel: true` for independent commands
- Optimize glob patterns to minimize file scanning
- Consider using `tags` to group related commands

### 3. Error Handling

- Provide meaningful error messages with `fail_text`
- Use appropriate exit codes in custom scripts
- Log errors for debugging purposes

### 4. Development Workflow

- Test hooks locally before committing
- Never use `--no-verify` (per user preferences)
- Keep hooks fast to avoid interrupting development flow

### 5. Team Collaboration

- Document any required setup steps
- Ensure all team members can reproduce the environment
- Use consistent tool versions across the team

### 6. Security Considerations

- Never commit sensitive data like API keys
- Use environment variables for secrets
- Regularly update dependencies and tools

## Additional Resources

- [Lefthook Documentation](https://github.com/evilmartians/lefthook)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Make Manual](https://www.gnu.org/software/make/manual/)
- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [MCP Protocol Documentation](https://modelcontextprotocol.io/)

## Using prompts

Prompts live under `.github/prompts/` and provide concise, task-focused guidance aligned with our tooling.

- Start with `.github/prompts/rails-system-tests.prompt.md` to visually verify app behavior using Rails system tests (Cuprite).
- Use `.github/prompts/headless-visual-verification.prompt.md` when working on non-trivial visual/UI changes that should be empirically verified with headless browser tests (Puppeteer MCP or Playwright), aligned with Issue #982.
- Follow the commands as written to match CI: `mise run test-prepare`, `mise exec -- bin/rails test`, and `HEADLESS=true CUPRITE=true APP_HOST=localhost mise exec -- bin/rails test:system`.
- For additional deterministic visual checks, run the Puppeteer-based script described in `README.md` (e.g., `mise exec -- yarn visual:verify --urls "/,/search?query=coffee,/favorites"`) and diff the generated screenshots under `tmp/visual-verification`.
- Keep changes small and verify before/after using screenshots or focused temporary assertions.
- When headless visual verification or automated reviewers (Claude/Codex/etc.) surface issues, you **must address** those issues and mark the corresponding PR comments/threads as **resolved** before treating the PR as done.

## Project-Specific Notes

This project uses:
- `mise exec --` prefix for all commands (per project standards)
- Lefthook for CI/CD and coding standards enforcement
- Make commands for common development tasks
- Automated code review and PR polling scripts
- GitHub Actions for continuous integration

See the project's `lefthook.yml`, `Makefile`, and scripts directory for specific implementation details.
