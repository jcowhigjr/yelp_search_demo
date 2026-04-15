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

### Core Repo Commands

```bash
# Sync and orient the repo
./scripts/git-sync.sh

# Create a new feature branch
git switch -c fix/some-issue

# Stack helpers
scripts/stacked-pr.sh create feature/foo-child
scripts/stacked-pr.sh sync
scripts/stacked-pr.sh show
scripts/stacked-pr.sh queue

# Run configured hooks manually
mise exec -- lefthook run pre-commit
mise exec -- lefthook run pre-push

# Install/reinstall git hooks
lefthook install
```

## 🚫 What's Prevented

- ❌ Direct commits to `main` or `develop` branches
- ❌ Pushing code that fails tests
- ❌ Pushing code with security vulnerabilities
- ❌ Pushing code that doesn't meet quality standards
- ❌ Pushing without proper environment setup

## 🎯 Recommended Workflow

1. **Start work**: `./scripts/git-sync.sh && git switch -c feature/my-feature`
2. **Stack follow-up work** (optional): `scripts/stacked-pr.sh create feature/my-feature-part-2`
3. **Make changes**: Edit your code
4. **Sync stack before push**: `scripts/stacked-pr.sh sync`
5. **Commit**: `git commit -m "Your message"` (automatic quality checks run)
6. **Push**: `git push origin feature/my-feature` (comprehensive testing runs)
7. **Queue PR**: `scripts/stacked-pr.sh queue`
8. **Create PR**: Use GitHub interface if auto-merge/queue is not enabled

## 🔧 Configuration

The workflow configuration is in `lefthook.yml`. Key sections:

- **pre-commit**: Branch protection and quality checks
- **pre-push**: Testing and security validation
- Repo helper scripts live under `scripts/` for sync, review-loop, PR lifecycle, and stacked PR flows

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
git switch -c feature/<name>
```

Additional rules:
1. **Never bypass lefthook**: The hooks are there for critical protections
2. **Use real repo entrypoints**: Prefer `./scripts/git-sync.sh`, `./scripts/review-loop.sh`, and `scripts/stacked-pr.sh` over stale wrapper names
3. **Understand the protections**: Know why branch protection exists
4. **Fix issues properly**: If hooks fail, fix the underlying issue, don't skip hooks

## 🆘 Troubleshooting

```bash
# Reinstall hooks if they're not working
lefthook install

# Skip hooks only in emergencies (NOT recommended)
git commit --no-verify
git push --no-verify

# Sync/orient current state
./scripts/git-sync.sh

# Run configured local checks
mise exec -- lefthook run pre-commit
mise exec -- lefthook run pre-push
```

Remember: The hooks are your safety net. They prevent broken code from reaching production and enforce team coding standards.
