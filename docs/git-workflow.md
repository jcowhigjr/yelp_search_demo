# Git Workflow with Lefthook

**🤖 IMPORTANT FOR AI AGENTS**: This project uses [Lefthook](https://github.com/evilmartians/lefthook) as the primary tool for git workflow management and quality assurance. Before making any git operations, agents should use the lefthook commands documented below to ensure proper workflow compliance.

This project uses [Lefthook](https://github.com/evilmartians/lefthook) as the primary tool for git workflow management and quality assurance.

## 🛡️ Automatic Protections

Lefthook automatically enforces these protections:

### Pre-Commit Hooks

- **Branch Protection**: Prevents direct commits to `main` and `develop` branches
- **Branch Sync Check**: Warns if your branch is behind remote
- **Code Quality**: Runs rubocop, erb_lint, prettier automatically
- **YAML Validation**: Ensures configuration files are valid

### Pre-Push Hooks

- **Comprehensive Testing**: Rails tests, system tests, next tests
- **Security Audits**: Brakeman, gem audit, JavaScript audit
- **Environment Validation**: Ensures development environment is properly configured
- **Import Map Audits**: Checks for outdated dependencies

## 🔧 Manual Workflow Commands

### Core Lefthook Commands

```bash
# Check current workflow status
lefthook run workflow-status

# Create a new feature branch (requires feature name as argument)
lefthook run workflow-new-feature fix/some-issue

# Stack helpers (new!)
lefthook run workflow-stack-create feature/foo-child
lefthook run workflow-stack-sync          # rebases current branch on parent
lefthook run workflow-stack-show          # prints parent chain
lefthook run workflow-queue-pr            # runs readiness + queues auto-merge

# Run code quality fixes
lefthook run fixer

# Install/reinstall git hooks
lefthook install
```

### Alternative: Safe Workflow Script

For more user-friendly commands, you can also use the `bin/safe-workflow` script:

```bash
# Check status with guidance
bin/safe-workflow status

# Create feature branch with interactive prompts
bin/safe-workflow new-feature fix/some-issue

# Pull latest changes safely
bin/safe-workflow pull-latest

# Commit with protections
bin/safe-workflow commit "Your message"

# Push with checks
bin/safe-workflow push
```

## 🚫 What's Prevented

- ❌ Direct commits to `main` or `develop` branches
- ❌ Pushing code that fails tests
- ❌ Pushing code with security vulnerabilities
- ❌ Pushing code that doesn't meet quality standards
- ❌ Pushing without proper environment setup

## 🎯 Recommended Workflow

1. **Start work**: `lefthook run workflow-new-feature feature/my-feature`
2. **Stack follow-up work** (optional): `lefthook run workflow-stack-create feature/my-feature-part-2`
3. **Make changes**: Edit your code
4. **Sync stack before push**: `lefthook run workflow-stack-sync`
5. **Commit**: `git commit -m "Your message"` (automatic quality checks run)
6. **Push**: `git push origin feature/my-feature` (comprehensive testing runs)
7. **Queue PR**: `lefthook run workflow-queue-pr`
8. **Create PR**: Use GitHub interface if auto-merge/queue is not enabled

## 🔧 Configuration

The workflow configuration is in `lefthook.yml`. Key sections:

- **pre-commit**: Branch protection and quality checks
- **pre-push**: Testing and security validation
- **fixer**: Automatic code formatting and fixes
- **workflow-\***: Custom workflow commands

## 📝 For Agent Coders

**🚨 ALWAYS START BY SYNCING THE REPOSITORY:**
```bash
./scripts/git-sync.sh
```

This must be the **first command** you run when starting work. It:
- Updates local develop branch from GitHub
- Cleans up merged branches
- Prevents conflicts from stale code
- Takes ~5 seconds

After syncing, create your branch:
```bash
lefthook run workflow-new-feature feature/<name>
```

Additional rules:
1. **Never bypass lefthook**: The hooks are there for critical protections
2. **Use lefthook commands**: Prefer `lefthook run workflow-status` over manual git commands
3. **Understand the protections**: Know why branch protection exists
4. **Fix issues properly**: If hooks fail, fix the underlying issue, don't skip hooks

## 🆘 Troubleshooting

```bash
# Reinstall hooks if they're not working
lefthook install

# Skip hooks only in emergencies (NOT recommended)
git commit --no-verify
git push --no-verify

# Check hook configuration
lefthook run workflow-status

# Run all quality fixes
lefthook run fixer
```

Remember: The hooks are your safety net. They prevent broken code from reaching production and enforce team coding standards.
