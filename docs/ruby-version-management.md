# Ruby Version Management

This document describes the process for managing Ruby versions in this project using `mise`.

## Overview

This project uses `mise` with the **core Ruby plugin** to manage Ruby versions. The Ruby version is specified in `mise.toml` as the single source of truth.

## Quick Reference

```bash
# Check current Ruby version
mise exec -- ruby -v

# List available Ruby versions (sorted, newest last)
mise ls-remote ruby

# Update Ruby version in mise.toml
mise use ruby@3.4.8  # or whatever version you need

# Install the updated Ruby version
mise install

# Verify installation
mise exec -- ruby -v
```

## Ruby Version Bump Process

### 1. Check for Latest Ruby Version

Instead of browsing the web, use mise to check available versions:

```bash
# List all available Ruby versions (newest at the bottom)
mise ls-remote ruby | tail -20

# Or filter for specific major.minor versions
mise ls-remote ruby | grep "^3.4"
```

### 2. Update Ruby Version in mise.toml

**IMPORTANT**: Always use the `mise` CLI to update the version - never manually edit `mise.toml`:

```bash
# Update to a specific version
mise use ruby@3.4.8

# This will automatically update mise.toml
```

### 3. Check for Other Ruby Version References

After updating `mise.toml`, search for any hardcoded Ruby version references that may need updating:

```bash
# Search for Ruby version patterns
rg "3\.3\.\d+" --type-add 'config:*.{yml,yaml,rb,toml}' -t config
rg "3\.4\.\d+" --type-add 'config:*.{yml,yaml,rb,toml}' -t config

# Common places to check:
# - .rubocop.yml (TargetRubyVersion)
# - .ruby-version-next (for next_rails compatibility testing)
# - Gemfile (commented ruby version lines)
# - bin/setup-* scripts
# - CI configuration files (.github/workflows/*.yml)
```

### 4. Review and Update Related Files

Based on the ripgrep results, update any files that contain hardcoded Ruby versions:

- **`.rubocop.yml`**: Update `TargetRubyVersion` if bumping major/minor version
- **`.ruby-version-next`**: Update if you're maintaining a separate "next" Ruby version for testing
- **Custom setup scripts**: Update any hardcoded version checks in `bin/setup-*` scripts
- **CI workflows**: Check GitHub Actions workflows for hardcoded Ruby versions

### 5. Install and Verify

```bash
# Install the new Ruby version
mise install

# Verify the installation
mise exec -- ruby -v

# Run bundle install to update Gemfile.lock with new Ruby version
mise exec -- bundle install
```

### 6. Test the Change

```bash
# Run the test suite
mise run test

# Run system tests
mise run test-system

# Run linters to ensure code is compatible
mise run lint

# Run security checks
mise run brakeman
```

## Important Notes

### Single Source of Truth

- `mise.toml` is the **only** place where the Ruby version should be managed
- Do NOT create `.ruby-version` files (they are ignored per `mise.toml` settings)
- All commands should be prefixed with `mise exec --` to ensure version consistency

### Patch Version Updates

Patch version updates (e.g., 3.3.10 → 3.3.11 or 3.4.4 → 3.4.8) typically do not require changes to other files, but always check:

1. Run `rg` to find any hardcoded references
2. Review the search results
3. Update only if the patch version is explicitly referenced

### Major/Minor Version Updates

When updating major or minor versions (e.g., 3.3.x → 3.4.x):

1. Update `.rubocop.yml` `TargetRubyVersion`
2. Review Ruby changelog for breaking changes
3. Check gem compatibility (run `bundle install` and address any issues)
4. Update CI workflows if they reference specific Ruby versions
5. Run comprehensive tests including system tests

## Common Issues

### Bundle Install Fails

If `bundle install` fails after updating Ruby:

```bash
# Clear bundler cache
mise exec -- bundle clean --force

# Reinstall gems
mise exec -- bundle install
```

### Gems Not Compatible

If certain gems aren't compatible with the new Ruby version:

1. Check gem documentation for compatible versions
2. Update gem versions in Gemfile if needed
3. Run `bundle update <gem_name>` for specific gems

### RuboCop Errors

If RuboCop shows errors after updating:

1. Update `.rubocop.yml` `TargetRubyVersion` to match new Ruby version
2. Run `mise exec -- bundle exec rubocop --auto-gen-config` to regenerate exclusions if needed

## CI/CD Considerations

The CI environment uses `mise` to manage Ruby versions, so:

1. CI will automatically use the version specified in `mise.toml`
2. No need to update separate CI configuration for Ruby versions
3. CI runs `mise install` as part of the setup process

## References

- [mise documentation](https://mise.jdx.dev/)
- [mise Ruby plugin](https://mise.jdx.dev/lang/ruby.html)
- Ruby changelog: Check specific version on [ruby-lang.org](https://www.ruby-lang.org/)
