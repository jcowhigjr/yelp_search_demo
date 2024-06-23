#!/bin/bash

# Check if frum is installed
if ! command -v frum &>/dev/null; then
    echo "frum is not installed. Please install frum first."
    exit 1
fi

# Get the latest available Ruby version from frum
latest_ruby_version=$(frum install -l | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | tail -n 1)

# Install the latest Ruby version
echo "Installing latest Ruby version: $latest_ruby_version"
frum install "$latest_ruby_version"

# Inform the user to potentially reload their shell environment
echo "The installation may require reloading your shell environment for changes to take effect."
echo "You can try running 'source ~/.zshrc' or opening a new terminal window."

exit 0
