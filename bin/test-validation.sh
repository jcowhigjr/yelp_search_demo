#!/usr/bin/env bash
set -eo pipefail

# Test failing case
echo "Testing invalid environment..."
mv mise.toml mise.toml.bak
trap 'mv mise.toml.bak mise.toml' EXIT
! git commit -am "test invalid state" 2>&1 | grep -q "Environment invalid"

# Test passing case
echo "Testing valid environment..."
touch docs/test-pass.md
git add docs/test-pass.md
git commit -m "chore: validation test pass"
rm docs/test-pass.md
