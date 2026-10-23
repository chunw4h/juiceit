#!/usr/bin/env bash

# uninstall_orange.sh – removes everything that install_orange.sh created.
# It is safe to run repeatedly. Use --force to skip interactive prompts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default locations (must match install_orange.sh)
HOME_DIR="$HOME"
MINICONDA="$HOME_DIR/miniconda3"
ENV_NAME="orange3"
APP_NAME="Orange3.app"
APP_DIR_USER="$HOME_DIR/Applications"
APP_DIR_SYS="/Applications"
DESKTOP_LINK="$HOME_DIR/Desktop/Orange3"
SETUP_LOG="$HOME_DIR/Library/Logs/Orange3_Course_setup.log"
LAUNCH_LOG="$HOME_DIR/Library/Logs/Orange3_Course_launch.log"

FORCE=0

usage() {
    cat <<'EOF'
Usage: uninstall_orange.sh [--force]

  Removes the orange3 Conda environment, the Miniconda sandbox, the
  native Orange3.app bundle (if it was created by the installer), the
  Desktop shortcut and the log files.

  Without --force the script asks for confirmation before each destructive
  step.
EOF
    exit 0
}

# Parse flags
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $arg" >&2; usage ;;
    esac
done

confirm() {
    local msg="$1"
    if (( FORCE )); then
        return 0
    fi
    read -p "$msg [y/N] " -r reply
    [[ $reply =~ ^[Yy]$ ]]
}

# Helper for colored output (reuse same colours as install script)
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RESET='\033[0m'

info() { echo -e "${C_YELLOW}$*${C_RESET}"; }
ok()   { echo -e "   ${C_GREEN}[OK]${C_RESET} $*"; }
fail() { echo -e "${C_RED}ERROR:${C_RESET} $*"; exit 1; }

info "Starting Orange3 uninstallation…"

# 1. Remove the Conda environment
if conda env list | grep -q "^$ENV_NAME " ; then
    if confirm "Remove Conda environment '$ENV_NAME'?"; then
        conda env remove -n "$ENV_NAME" --yes || fail "Failed to remove Conda env $ENV_NAME"
        ok "Conda environment '$ENV_NAME' removed"
    else
        info "Skipped Conda environment removal"
    fi
else
    info "Conda environment '$ENV_NAME' not found – nothing to remove"
fi

# 2. Delete the sandbox Miniconda folder (if it exists)
if [ -d "$MINICONDA" ]; then
    if confirm "Delete the Miniconda sandbox at $MINICONDA?"; then
        rm -rf "$MINICONDA"
        ok "Removed $MINICONDA"
    else
        info "Skipped Miniconda removal"
    fi
else
    info "Miniconda directory not found – nothing to delete"
fi

# 3. Remove the native .app bundle (user or system location)
remove_app() {
    local dir="$1"
    local app_path="$dir/$APP_NAME"
    if [ -e "$app_path" ]; then
        # Ensure we only delete a bundle the installer created
        if [ -e "$app_path/.juiceit-launcher" ]; then
            if confirm "Delete $app_path?"; then
                rm -rf "$app_path"
                ok "Deleted $app_path"
            else
                info "Skipped deletion of $app_path"
            fi
        else
            info "Found $app_path but it does not contain the installer marker – left untouched."
        fi
    fi
}

remove_app "$APP_DIR_USER"
remove_app "$APP_DIR_SYS"

# 4. Remove the Desktop shortcut
if [ -L "$DESKTOP_LINK" ] || [ -e "$DESKTOP_LINK" ]; then
    if confirm "Remove Desktop shortcut $DESKTOP_LINK?"; then
        rm -f "$DESKTOP_LINK"
        ok "Removed Desktop shortcut"
    else
        info "Skipped Desktop shortcut removal"
    fi
else
    info "Desktop shortcut not present"
fi

# 5. Clean up log files
for f in "$SETUP_LOG" "$LAUNCH_LOG"; do
    if [ -e "$f" ]; then
        if confirm "Delete log file $f?"; then
            rm -f "$f"
            ok "Deleted $f"
        else
            info "Skipped log file $f"
        fi
    fi
done

info "Uninstallation complete."
"]