#!/usr/bin/env bash
### This script is now a container entry point to install mise and all the tools in the project's mise.toml

#install apt or brew dependencies first

set -eou pipefail

# Detect operating system/architecture
os_type=$(uname -s)

if [ "$os_type" = "Darwin" ]; then
    # macOS setup
    echo " Configuring macOS environment"
    brew bundle --file="$(dirname "$0")/../Brewfile"
elif [ "$os_type" = "Linux" ]; then
    # Linux/CI setup
    echo " Configuring Linux environment"
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -qq
    xargs -a "$(dirname "$0")/../aptfile" sudo apt-get install -y -qq
    export BROWSER_PATH=$(which chromium) && echo $BROWSER_PATH
fi

# Check if mise is installed, otherwise install it
if ! command -v mise &>/dev/null; then
    curl -fsSL https://mise.run | bash -s -- --version latest 2>&1
    export PATH="$HOME/.local/bin:$PATH"
    echo "eval \"\$(/root/.local/bin/mise activate bash)\"" >>~/.bashrc
    eval "$(/root/.local/bin/mise activate bash)"
    mise settings experimental=true
fi

#check if mis is active
mise env

#install dependencies
mise install
mise exec -- lefthook install

# log versions
echo "Active versions:"
mise exec -- node --version
mise exec -- ruby --version
mise exec -- yarn --version

# refresh shims
mise reshim

# clean unused versions
mise prune --force

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

bin/setup

lefthook run fixer

exec "$@"
