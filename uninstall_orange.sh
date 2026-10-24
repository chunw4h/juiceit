#!/usr/bin/env bash
# uninstall_orange.sh – safe removal of the Orange3 course installation
# --------------------------------------------------------------
#  * removes the conda env "orange3"
#  * deletes the sandboxed Miniconda folder in $HOME
#  * removes the native .app bundle (if it contains the installer marker)
#  * removes the Desktop shortcut and the two log files
#  * --force  : run non‑interactively (no prompts)
# --------------------------------------------------------------

set -euo pipefail   # abort on error, treat unset vars as errors, fail pipelines

# -----------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------
msg() { printf "\n%s\n" "$*"; }
ask() {
    # $1 = question, $2 = default (y/n)
    local default="${2:-y}"
    local prompt="[${default^^}]"
    read -r -p "$(printf "%s %s " "$1" "$prompt")" reply
    reply="${reply:-$default}"
    [[ "$reply" =~ ^[Yy]$ ]]
}
# -----------------------------------------------------------------
# Parse flags
# -----------------------------------------------------------------
FORCE=0
while (( $# )); do
    case "$1" in
        --force) FORCE=1 ;;
        *) echo "Unknown flag: $1" >&2; exit 1 ;;
    esac
    shift
done

# -----------------------------------------------------------------
# Paths & constants
# -----------------------------------------------------------------
ENV_NAME="orange3"
MINICONDA_DIR="${HOME}/miniconda3"
APP_PATH="${HOME}/Applications/Orange3.app"
DESKTOP_LINK="${HOME}/Desktop/Orange3"
SETUP_LOG="${HOME}/Library/Logs/Orange3_Course_setup.log"
LAUNCH_LOG="${HOME}/Library/Logs/Orange3_Course_launch.log"

# -----------------------------------------------------------------
# Begin uninstallation
# -----------------------------------------------------------------
msg "Starting Orange3 uninstallation…"

# 1️⃣ Conda environment
if conda env list | grep -qE "^${ENV_NAME}[[:space:]]"; then
    if (( FORCE )) || ask "Remove Conda environment '${ENV_NAME}'?" y; then
        conda env remove -n "${ENV_NAME}"
        msg "Conda environment '${ENV_NAME}' removed."
    else
        msg "Skipped Conda environment removal."
    fi
else
    msg "No conda environment named '${ENV_NAME}' – nothing to remove."
fi

# 2️⃣ Miniconda sandbox
if [[ -d "${MINICONDA_DIR}" ]]; then
    if (( FORCE )) || ask "Delete sandbox Miniconda at '${MINICONDA_DIR}'?" y; then
        rm -rf "${MINICONDA_DIR}"
        msg "Miniconda sandbox removed."
    else
        msg "Skipped Miniconda removal."
    fi
else
    msg "No Miniconda sandbox found – nothing to remove."
fi

# 3️⃣ .app bundle (only if it was created by the installer)
if [[ -d "${APP_PATH}" ]]; then
    if [[ -f "${APP_PATH}/.juiceit-launcher" ]]; then
        if (( FORCE )) || ask "Delete Orange3.app at '${APP_PATH}'?" y; then
            rm -rf "${APP_PATH}"
            msg "Orange3.app removed."
        else
            msg "Skipped deletion of '${APP_PATH}'."
        fi
    else
        msg "Found ${APP_PATH} but it does not contain the installer marker – left untouched."
    fi
else
    msg "No Orange3.app bundle found."
fi

# 4️⃣ Desktop shortcut
if [[ -L "${DESKTOP_LINK}" ]]; then
    if (( FORCE )) || ask "Remove Desktop shortcut?" y; then
        rm -f "${DESKTOP_LINK}"
        msg "Desktop shortcut removed."
    else
        msg "Skipped Desktop shortcut removal."
    fi
else
    msg "No Desktop shortcut present."
fi

# 5️⃣ Log files
for LOG in "${SETUP_LOG}" "${LAUNCH_LOG}"; do
    if [[ -f "${LOG}" ]]; then
        if (( FORCE )) || ask "Delete log file '${LOG}'?" y; then
            rm -f "${LOG}"
            msg "Log file '${LOG}' deleted."
        else
            msg "Skipped log file '${LOG}'."
        fi
    else
        msg "Log file '${LOG}' not found."
    fi
done

msg "Uninstallation complete."
