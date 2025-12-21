#!/bin/bash
# Validate mise.toml configuration

# Exit on error
set -e

# Check for invalid plugin configurations
if grep -q '^\[plugins\]' mise.toml; then
    echo "Error: [plugins] section should not be present in mise.toml"
    echo "Remove any [plugins] section as Ruby is a core plugin in mise"
    exit 1
fi

# Validate TOML syntax
if command -v taplo >/dev/null 2>&1; then
    taplo lint mise.toml
else
    echo "Warning: taplo not installed, skipping TOML syntax validation"
    echo "Install with: cargo install taplo-cli"
fi

exit 0
