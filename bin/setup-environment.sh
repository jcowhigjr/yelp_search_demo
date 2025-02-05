#!/usr/bin/env bash
### This script is now a container entry point to install mise and all the tools in the project's mise.toml

#install apt or brew dependencies first

# Detect operating system/architecture
os_type=$(uname -s)
if [ "$os_type" = "Darwin" ]; then
    echo "Detected macOS, installing brew dependencies"
    brew bundle --file="$(dirname "$0")/../Brewfile"
else
    echo "Detected Linux, installing apt dependencies"
    xargs -a "$(dirname "$0")/../aptfile" sudo apt-get install -y
    export BROWSER_PATH=$(which chromium) && echo $BROWSER_PATH
fi

# Check if mise is installed, otherwise install it
if [ -x "$(command -v mise)" ]; then
    echo "Mise is installed"
    eval "$(/root/.local/bin/mise activate bash)"
    mise env
else
    echo "Installing mise"
    curl https://mise.run | bash
    echo "eval \"\$(/root/.local/bin/mise activate bash)\"" >>~/.bashrc
    eval "$(/root/.local/bin/mise activate bash)"
    mise settings experimental=true
fi

mise install
yarn install
corepack enable

lefthook install
bin/setup
lefthook run fixer
