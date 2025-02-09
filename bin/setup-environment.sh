#!/usr/bin/env bash
### This script is now a container entry point to install mise and all the tools in the project's mise.toml

#install apt or brew dependencies first

set -eou pipefail

# Detect operating system/architecture
os_type=$(uname -s)
if [ "$os_type" = "Darwin" ]; then
    echo "Detected macOS, installing brew dependencies"
    brew bundle --file="$(dirname "$0")/../Brewfile"
else
    echo "Detected Linux, installing apt dependencies"
    xargs -a "$(dirname "$0")/../aptfile" sudo apt-get install -y -qq
    export BROWSER_PATH=$(which chromium) && echo $BROWSER_PATH
fi

# Check if mise is installed, otherwise install it
if [ -x "$(command -v mise)" ]; then
    echo "Mise is installed"
else
    echo "Installing mise"
    command -v curl >/dev/null || {
        echo "Error: curl required but not found"
        exit 1
    }
    curl -fsSL https://mise.run | bash -s -- --version latest 2>&1
    echo "eval \"\$(/root/.local/bin/mise activate bash)\"" >>~/.bashrc
    eval "$(/root/.local/bin/mise activate bash)"
    mise settings experimental=true
fi

#check if mis is active
mise env

#install dependencies
mise install

# refresh shims
mise reshim

# clean unused versions
mise prune

#add mise shims to the path
export PATH="${HOME}/.local/bin:$PATH"
export PATH="${HOME}/.local/share/mise/shims:$PATH"

# can this be moved to mise.toml?

yarn install
if [ -f /.dockerenv ]; then
    echo "Initializing container environment..."
    corepack enable
    lefthook install
fi
lefthook run fixer
bin/setup

exec "$@"
