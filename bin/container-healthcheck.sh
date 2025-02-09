#!/usr/bin/env bash
set -eo pipefail

# Validation-only mode
mise ls --current | grep -qF "ruby@3.4.1" || exit 1
mise ls --current | grep -qF "lefthook@1.10.10" || exit 1
