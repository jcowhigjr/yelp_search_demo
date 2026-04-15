# Agent Coder Workflow Guide

**🤖 FOR AI AGENTS WORKING ON THIS PROJECT**

This project has automated git workflow protections via Lefthook. **You MUST use these commands** instead of direct git operations to ensure compliance with project standards.

## ⚠️ CRITICAL: Required Commands for Agent Coders

### Before Starting Any Work

```bash
# 1. Sync and orient the repo (ALWAYS run this first)
./scripts/git-sync.sh

# 2. If you need to create a new feature branch
git switch -c fix/description-of-fix
```

### Making Changes

```bash
# 3. Run the actual configured local checks before committing
mise exec -- lefthook run pre-commit

# 4. Normal git operations are now safe (lefthook will protect you)
git add .
git commit -m "Your commit message"
git push
```

## 🛡️ Automatic Protections You'll Encounter

- **Branch Protection**: Cannot commit directly to `main` or `develop`
- **Quality Checks**: Rubocop, prettier, ERB lint run automatically
- **Testing**: Comprehensive test suite runs on push
- **Security**: Brakeman, gem audits, JS audits run automatically

## 🚨 If You Get Blocked

If lefthook prevents an operation:

1. **Read the error message carefully** - it usually tells you exactly what to do
2. **Use the repo scripts and real hook names** instead of trying to bypass
3. **Run `./scripts/git-sync.sh`** to refresh local state
4. **Run `mise exec -- lefthook run pre-commit`** to reproduce configured checks

## ❌ DO NOT Do These Things

- Don't commit directly to `main` or `develop` branches
- Don't bypass lefthook with `--no-verify` flags
- Don't use raw `git checkout -b` for feature branches
- Don't push without running quality checks

## ✅ Example Workflow for Agent Coders

```bash
# Start work
./scripts/git-sync.sh                           # Refresh local state
git switch -c fix/bug-123                       # Create feature branch

# Make changes to files...

# Finish work
mise exec -- lefthook run pre-commit            # Run configured local checks
git add .                                       # Stage changes
git commit -m "Fix bug 123"                    # Commit (pre-commit hooks run)
git push                                        # Push (pre-push tests run)
```

This ensures your changes meet project standards and don't break the CI pipeline.
