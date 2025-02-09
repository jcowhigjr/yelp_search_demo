# Container Organization Guide

## Mise-en-Place Principles
- **Tool Version Isolation**: Pinned runtime versions in mise.toml
- **Path Hierarchy**: `~/.local/bin` before system paths
- **Health Verification**: Version checks in container-healthcheck.sh
- **Process Management**: Entrypoint pattern with `exec "$@"`

## Maintenance Operations
```bash
# Update tool versions
mise install

# Verify container health
./bin/container-healthcheck.sh

# Clean version cache
mise prune
```
## Git Hook Validation
- Pre-commit environment verification
- Pre-push CI readiness check
- Tag-based skip options (`--skip-validation`)
## Recovery Workflow

If environment validation fails:

1. Restore mise configuration
```bash
mv mise.toml.bak mise.toml  # If backup exists
./bin/setup-environment.sh

## Healthcheck Philosophy
- **Validation Only** - Never modifies environment
- **Idempotent** - Safe to run repeatedly
- **Fast** - Executes in <1s