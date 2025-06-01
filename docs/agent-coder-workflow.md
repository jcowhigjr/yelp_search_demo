# Agent Coder Workflow Guide

**🤖 FOR AI AGENTS WORKING ON THIS PROJECT**

This project has automated git workflow protections via Lefthook. **You MUST use these commands** instead of direct git operations to ensure compliance with project standards.

## ⚠️ CRITICAL: Required Commands for Agent Coders

### Before Starting Any Work

```bash
# 1. Check current workflow status (ALWAYS run this first)
lefthook run workflow-status

# 2. If you need to create a new feature branch
lefthook run workflow-new-feature fix/description-of-fix
```

### Making Changes

```bash
# 3. Run code quality fixes before committing
lefthook run fixer

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
2. **Use the suggested lefthook commands** instead of trying to bypass
3. **Check `lefthook run workflow-status`** to understand current state
4. **Run `lefthook run fixer`** to auto-fix code quality issues

## ❌ DO NOT Do These Things

- Don't commit directly to `main` or `develop` branches
- Don't bypass lefthook with `--no-verify` flags
- Don't use raw `git checkout -b` for feature branches
- Don't push without running quality checks

## ✅ Example Workflow for Agent Coders

```bash
# Start work
lefthook run workflow-status                    # Check current state
lefthook run workflow-new-feature fix/bug-123   # Create feature branch

# Make changes to files...

# Finish work
lefthook run fixer                              # Fix code quality
git add .                                       # Stage changes
git commit -m "Fix bug 123"                    # Commit (pre-commit hooks run)
git push                                        # Push (pre-push tests run)
```

This ensures your changes meet project standards and don't break the CI pipeline.
