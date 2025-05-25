#!/usr/bin/env bash
### This script is now a container entry point to install mise and all the tools in the project's mise.toml

#install apt or brew dependencies first

set -eou pipefail

# Enforce project isolation
export MISE_CONFIG_DIR="$PWD/.mise"
export MISE_DEFAULT_CONFIG_FILE="$PWD/mise.toml"
export MISE_DEFAULT_TOOL_VERSIONS_FILENAME=mise.toml

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
    echo "mise not found, installing..."
    curl -fsSL -o /tmp/install-mise.sh https://mise.run
    bash /tmp/install-mise.sh # Assuming the installer script handles its own flags like --version latest
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.local/share/mise/shims:$PATH" # Add shims path earlier
    # Removed .bashrc modification
    # Removed eval of mise activate bash
    # Check if mise is now available
    if ! command -v mise &>/dev/null; then
        echo "mise installation failed."
        exit 1
    fi
    echo "mise installed. Configuring..."
    mise settings experimental=true # This should now work if mise is in PATH
fi

# Add trust command
mise trust "$PWD"

#check if mis is active
mise env

#install dependencies
mise install

# log versions
# echo "Active versions:"
# mise exec -- node --version
# mise exec -- ruby --version
# mise exec -- yarn --version
# mise exec -- lefthook --version

# refresh shims
mise reshim

# clean unused versions
mise prune --yes

#add mise shims to the path
export PATH="${HOME}/.local/bin:$PATH"
export PATH="${HOME}/.local/share/mise/shims:$PATH"

# can this be moved to mise.toml?

if [ -f /.dockerenv ]; then
    echo "Initializing container environment..."
    corepack enable
fi

exec "$@"
