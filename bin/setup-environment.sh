#!/usr/bin/env bash
# This script ensures mise is installed and sets up the project environment.

set -eou pipefail

# --- Helper Functions ---
echo_info() {
  echo "INFO: $1"
}
echo_error() {
  echo "ERROR: $1" >&2
}

# Determine whether mise is managed by Homebrew (skip self-update in that case)
is_brew_managed_mise() {
  local path="$1"
  [[ "$path" == "/usr/local/bin/mise" || "$path" == "/opt/homebrew/bin/mise" ]]
}

# Run mise self-update when it is not managed by Homebrew
maybe_self_update_mise() {
  if is_brew_managed_mise "$MISE_CMD"; then
    echo_info "Skipping mise self-update because Homebrew should manage updates."
    return
  fi

  echo_info "Attempting mise self-update to refresh tool definitions..."
  if ! "$MISE_CMD" self-update; then
    echo_info "mise self-update failed or was not necessary. Continuing."
  else
    echo_info "mise self-update completed successfully."
  fi
}

# Ensure the Ruby plugin uses the correct asdf-ruby source.
ensure_ruby_plugin() {
  local plugin_source="https://github.com/asdf-vm/asdf-ruby.git"
  echo_info "Ensuring Ruby plugin is installed from ${plugin_source}..."

  if "$MISE_CMD" plugins install --force ruby "$plugin_source"; then
    echo_info "Ruby plugin installed or refreshed from ${plugin_source}."
  else
    echo_error "Failed to install Ruby plugin from ${plugin_source}."
    exit 1
  fi
}

# --- Project Root ---
# Assuming the script is in project_root/bin/
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
echo_info "Project root: $PROJECT_ROOT"

# --- Global Variables ---
MISE_CMD=""

# --- Function to find or install mise ---
find_or_install_mise() {
  echo_info "Searching for mise..."

  # 1. Check if mise is already in PATH and executable
  if command -v mise &>/dev/null && mise --version &>/dev/null; then
    MISE_CMD=$(command -v mise)
    echo_info "Found mise in PATH: $MISE_CMD ($($MISE_CMD --version))"
  fi

  # 2. Check common installation paths if not found in PATH
  # Homebrew on macOS (Intel)
  if [[ -z "$MISE_CMD" && -x "/usr/local/bin/mise" ]]; then
    MISE_CMD="/usr/local/bin/mise"
    echo_info "Found mise at /usr/local/bin/mise ($($MISE_CMD --version))"
  # Homebrew on macOS (Apple Silicon)
  elif [[ -z "$MISE_CMD" && -x "/opt/homebrew/bin/mise" ]]; then
    MISE_CMD="/opt/homebrew/bin/mise"
    echo_info "Found mise at /opt/homebrew/bin/mise ($($MISE_CMD --version))"
  # Direct install path
  elif [[ -z "$MISE_CMD" && -x "$HOME/.local/bin/mise" ]]; then
    MISE_CMD="$HOME/.local/bin/mise"
    echo_info "Found mise at $HOME/.local/bin/mise ($($MISE_CMD --version))"
  fi

  # 3. If still not found, attempt to install it
  if [[ -z "$MISE_CMD" ]]; then
    echo_info "mise not found. Attempting to install via official script..."

    INSTALL_OK=0

    # Primary install attempt with retries (GitHub outages have caused flakes)
    if curl -fsSL --retry 3 --retry-delay 2 https://mise.run | sh; then
      INSTALL_OK=1
    else
      echo_error "Primary install via https://mise.run failed. Trying fallback installer from GitHub..."
      # Fallback to the raw GitHub installer (separate CDN path from mise.run)
      if curl -fsSL --retry 3 --retry-delay 2 https://raw.githubusercontent.com/jdx/mise/main/install.sh | sh; then
        INSTALL_OK=1
      fi
    fi

    if [[ "$INSTALL_OK" -ne 1 ]]; then
      echo_error "Failed to install mise using the official or fallback installer."
      exit 1
    fi

    MISE_CMD="$HOME/.local/bin/mise"
    if [ ! -x "$MISE_CMD" ]; then
      echo_error "mise installation script ran, but $MISE_CMD is not executable or not found at the expected path."
      exit 1
    fi

    echo_info "mise installed successfully to $MISE_CMD ($($MISE_CMD --version))"
    echo_info "Please re-source your shell profile or open a new terminal, then re-run setup."
  fi

  # Ensure MISE_CMD is set
  if [[ -z "$MISE_CMD" ]]; then
    echo_error "MISE_CMD could not be determined. mise is not installed or not found."
    exit 1
  fi
}

# --- Main Script Execution ---
find_or_install_mise

# Ensure mise has the latest definitions before installing project tools
maybe_self_update_mise

echo_info "Using mise executable: $MISE_CMD"

# Create a backup of mise.toml to prevent corruption issues
if [ -f "$PROJECT_ROOT/mise.toml" ] && [ ! -f "$PROJECT_ROOT/mise.toml.backup" ]; then
  echo_info "Creating backup of mise.toml..."
  cp "$PROJECT_ROOT/mise.toml" "$PROJECT_ROOT/mise.toml.backup"
fi

# Configure mise settings (idempotent)
echo_info "Configuring mise settings..."
# Small delay to prevent race conditions with file system operations
sleep 0.5
"$MISE_CMD" settings experimental true
"$MISE_CMD" settings legacy_version_file true # Important if using .tool-versions or similar
"$MISE_CMD" settings all_compile true # Ensure tools like Ruby are compiled if necessary

# Trust the project's mise configuration
echo_info "Trusting project's mise configuration ($PROJECT_ROOT/mise.toml)..."
# Small delay to prevent race conditions with TOML file access
sleep 0.3

# Check for TOML corruption before trusting
if ! "$MISE_CMD" trust --yes "$PROJECT_ROOT/mise.toml" 2>/dev/null; then
  echo_error "Failed to trust $PROJECT_ROOT/mise.toml. Checking for corruption..."
  
  # Check if the file appears corrupted (common pattern: missing opening bracket)
  if head -1 "$PROJECT_ROOT/mise.toml" | grep -q "ple\[env\]"; then
    echo_error "TOML file appears corrupted. Attempting recovery..."
    
    # Try to restore from backup if available
    if [ -f "$PROJECT_ROOT/mise.toml.backup" ]; then
      echo_info "Restoring from backup..."
      cp "$PROJECT_ROOT/mise.toml.backup" "$PROJECT_ROOT/mise.toml"
      echo_info "Backup restored. Retrying trust..."
      
      if ! "$MISE_CMD" trust --yes "$PROJECT_ROOT/mise.toml"; then
        echo_error "Still failed to trust mise.toml after backup restoration."
        exit 1
      fi
    else
      echo_error "No backup available. Manual intervention required."
      exit 1
    fi
  else
    echo_error "Trust failed for unknown reason. Check permissions or mise setup."
    exit 1
  fi
fi

# Ensure the correct Ruby plugin is available before installing tools
ensure_ruby_plugin

# Install project tools as defined in mise.toml
echo_info "Installing project tools with mise (from $PROJECT_ROOT/mise.toml)..."
# Small delay to prevent race conditions with TOML file access
sleep 0.3
INSTALL_FAILED=0
if [ "${SETUP_SKIP_NODE:-false}" = "true" ]; then
  echo_info "SETUP_SKIP_NODE is true. Temporarily hiding Node.js ecosystem files to prevent auto-detection."
  
  # Temporarily rename Node.js ecosystem files to prevent mise auto-detection
  TEMP_FILES=()
  if [ -f "$PROJECT_ROOT/package.json" ]; then
    mv "$PROJECT_ROOT/package.json" "$PROJECT_ROOT/package.json.temp"
    TEMP_FILES+=("package.json")
  fi
  if [ -f "$PROJECT_ROOT/yarn.lock" ]; then
    mv "$PROJECT_ROOT/yarn.lock" "$PROJECT_ROOT/yarn.lock.temp"
    TEMP_FILES+=("yarn.lock")
  fi
  if [ -f "$PROJECT_ROOT/.yarnrc.yml" ]; then
    mv "$PROJECT_ROOT/.yarnrc.yml" "$PROJECT_ROOT/.yarnrc.yml.temp"
    TEMP_FILES+=(".yarnrc.yml")
  fi
  
  echo_info "Hidden files: ${TEMP_FILES[*]}"
  echo_info "Installing Ruby only (Node.js ecosystem files temporarily hidden)."
  
  # Install only Ruby to avoid Node.js compilation
  if ! "$MISE_CMD" install ruby; then
    INSTALL_FAILED=1
  fi
  
  # Restore the Node.js ecosystem files
  echo_info "Restoring Node.js ecosystem files..."
  for file in "${TEMP_FILES[@]}"; do
    if [ -f "$PROJECT_ROOT/$file.temp" ]; then
      mv "$PROJECT_ROOT/$file.temp" "$PROJECT_ROOT/$file"
      echo_info "Restored $file"
    fi
  done
else
  echo_info "Installing all tools defined in mise.toml..."
  if ! "$MISE_CMD" install; then
    INSTALL_FAILED=1
  fi
fi

if [ "$INSTALL_FAILED" -eq 1 ]; then
  echo_error "mise install failed. Check mise.toml and tool plugin availability."
  exit 1
fi
echo_info "All selected mise-managed tools are installed/updated."

# Refresh mise shims
echo_info "Refreshing mise shims..."
# Small delay to prevent race conditions with TOML file access
sleep 0.3
if ! "$MISE_CMD" reshim 2>/dev/null; then
  echo_info "mise reshim encountered an issue (likely TOML parsing race condition). Retrying after delay..."
  sleep 1
  if ! "$MISE_CMD" reshim 2>/dev/null; then
    echo_error "mise reshim failed after retry. This is non-critical but may affect tool availability."
  else
    echo_info "mise reshim succeeded on retry."
  fi
fi

# Clean up unused tool versions (optional, but good practice)
echo_info "Pruning old/unused tool versions managed by mise..."
# Small delay to prevent race conditions with TOML file access
sleep 0.3
if ! "$MISE_CMD" prune --yes 2>/dev/null; then
  echo_info "mise prune encountered an issue (likely TOML parsing race condition). Retrying after delay..."
  sleep 1
  if ! "$MISE_CMD" prune --yes 2>/dev/null; then
    echo_error "mise prune failed after retry. This is non-critical and may be due to transient file system issues."
  else
    echo_info "mise prune succeeded on retry."
  fi
fi

# Output the MISE_EXECUTABLE_PATH for the calling script (bin/setup)
# This is a key part for bin/setup to know which mise to use.
echo "MISE_EXECUTABLE_PATH:$MISE_CMD"

echo_info "Mise environment setup complete."

# Log key tool versions for verification (using the found mise)
echo_info "Key tool versions (via mise exec):"
# Small delay to prevent race conditions with TOML file access
sleep 0.3
"$MISE_CMD" exec -- ruby --version
if [ "${SETUP_SKIP_NODE:-false}" != "true" ]; then
  "$MISE_CMD" exec -- node --version
  "$MISE_CMD" exec -- yarn --version # Assuming yarn is tied to Node.js presence
fi

if [ -f /.dockerenv ]; then
    echo_info "Initializing container-specific environment settings..."
    # Example: corepack enable, if needed and managed outside mise for containers
    # if command -v corepack &>/dev/null; then
    #   corepack enable
    # fi
fi

echo_info "Environment setup script finished."

# If this script is called with arguments, execute them within the mise environment
if [ "$#" -gt 0 ]; then
  echo_info "Executing command(s) within mise environment: $@"
  exec "$MISE_CMD" exec -- "$@"
else
  echo_info "No further commands to execute by setup-environment.sh itself."
fi
