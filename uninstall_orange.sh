#!/usr/bin/env bash
# uninstall_orange.sh – remove everything install_orange.sh created.
#
# Usage: bash uninstall_orange.sh [--force]
#   --force  Skip all confirmation prompts.

set -euo pipefail

ENV_NAME="orange3"
MINICONDA_DIR="$HOME/miniconda3"
MARKER=".juiceit-launcher"
DESKTOP_LINK="$HOME/Desktop/Orange3"
SETUP_LOG="$HOME/Library/Logs/Orange3_Course_setup.log"
LAUNCH_LOG="$HOME/Library/Logs/Orange3_Course_launch.log"

FORCE=0

msg() { printf '\n%s\n' "$*"; }

usage() {
    cat <<'EOF'
Usage: bash uninstall_orange.sh [--force]

  (default)   Ask before removing each item.
  --force     Remove everything without prompting.
  -h, --help  Show this help.
EOF
}

# Ask a yes/no question. Reads from the terminal, not stdin, so this works
# when the script is piped (`curl ... | bash`). Falls back to the default
# answer when no terminal is available.
ask() {
    local prompt="$1" default="${2:-y}" hint reply

    if (( FORCE )); then
        return 0
    fi

    if [ "$default" = "y" ]; then hint="[Y/n]"; else hint="[y/N]"; fi

    printf '%s %s ' "$prompt" "$hint"
    if ! read -r reply 2>/dev/null < /dev/tty; then
        reply="$default"
    fi
    reply="${reply:-$default}"

    [[ "$reply" =~ ^[Yy]$ ]]
}

# --- Flags -------------------------------------------------------------------

for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; usage >&2; exit 1 ;;
    esac
done

# --- Uninstall ---------------------------------------------------------------

msg "Starting Orange3 uninstallation…"

# 1) Conda environment (removing the directory is what `conda env remove` does,
#    without needing conda, ToS acceptance, or a sourced shell).
if [ -d "$MINICONDA_DIR/envs/$ENV_NAME" ]; then
    if ask "Remove Conda environment '$ENV_NAME'?"; then
        rm -rf "$MINICONDA_DIR/envs/$ENV_NAME"
        msg "Conda environment '$ENV_NAME' removed."
    else
        msg "Skipped Conda environment removal."
    fi
else
    msg "No conda environment named '$ENV_NAME' – nothing to remove."
fi

# 2) Miniconda sandbox
if [ -d "$MINICONDA_DIR" ]; then
    if ask "Delete sandbox Miniconda at '$MINICONDA_DIR'?"; then
        rm -rf "$MINICONDA_DIR" || msg "Could not fully remove $MINICONDA_DIR."
        msg "Miniconda sandbox removed."
    else
        msg "Skipped Miniconda removal."
    fi
else
    msg "No Miniconda sandbox found – nothing to remove."
fi

# 3) .app bundle (installer prefers /Applications, falls back to ~/Applications)
for APP_PATH in "$HOME/Applications/Orange3.app" "/Applications/Orange3.app"; do
    if [ ! -d "$APP_PATH" ]; then
        continue
    fi
    if [ ! -e "$APP_PATH/$MARKER" ]; then
        msg "Found $APP_PATH but it does not contain the installer marker – left untouched."
        continue
    fi
    if ask "Delete Orange3.app at '$APP_PATH'?"; then
        if rm -rf "$APP_PATH" 2>/dev/null; then
            msg "Orange3.app removed from $APP_PATH."
        else
            msg "Could not remove $APP_PATH – re-run with sudo."
        fi
    else
        msg "Skipped deletion of '$APP_PATH'."
    fi
done

# 4) Desktop shortcut
if [ -L "$DESKTOP_LINK" ]; then
    if ask "Remove Desktop shortcut?"; then
        rm -f "$DESKTOP_LINK"
        msg "Desktop shortcut removed."
    else
        msg "Skipped Desktop shortcut removal."
    fi
else
    msg "No Desktop shortcut present."
fi

# 5) Log files
for LOG in "$SETUP_LOG" "$LAUNCH_LOG"; do
    if [ -f "$LOG" ]; then
        if ask "Delete log file '$LOG'?"; then
            rm -f "$LOG"
            msg "Log file '$LOG' deleted."
        else
            msg "Skipped log file '$LOG'."
        fi
    else
        msg "Log file '$LOG' not found."
    fi
done

msg "Uninstallation complete."
