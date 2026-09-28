#!/bin/bash

# ==========================================
# 0. UI Colors & Setup Variables
# ==========================================
C_RESET='\033[0m'
C_CYAN='\033[0;36m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'

SETUP_LOG="$HOME/Library/Logs/Orange3_Course.log"
APP_DIR="$HOME/Applications"
APP_PATH="$APP_DIR/Orange3.app"

VERBOSE=0
QUIET_FLAG="--quiet"
ADDONS_CONDA="orange3-imageanalytics"
ADDONS_PIP="Orange3-Text Orange3-Timeseries Orange3-Geo Orange3-Associate"

clear
echo -e "${C_CYAN}${C_BOLD}==================================================${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}    Starting Orange3 Automated macOS Setup       ${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}==================================================${C_RESET}"
echo "A detailed technical log is being saved to:"
echo "$SETUP_LOG"
echo "--------------------------------------------------"

echo "Orange3 Installation Log - $(date)" > "$SETUP_LOG"

run_cmd() {
    if [ "$VERBOSE" = 1 ]; then
        "$@" 2>&1 | tee -a "$SETUP_LOG"
    else
        "$@" >> "$SETUP_LOG" 2>&1
    fi
}

echo -e "${C_CYAN}[1/6] Checking system for previous installations...${C_RESET}"
if [ -x "$HOME/miniconda3/bin/conda" ]; then
    echo "   ↳ Miniconda already detected."
elif [ -d "$HOME/miniconda3" ]; then
    echo "   ↳ Incomplete installation found. Creating backup..."
    mv "$HOME/miniconda3" "$HOME/miniconda3_backup_$(date +%Y%m%d_%H%M%S)" >> "$SETUP_LOG" 2>&1
fi

if [ ! -x "$HOME/miniconda3/bin/conda" ]; then
    echo -e "${C_CYAN}[2/6] Downloading Miniconda installer for $(uname -m)...${C_RESET}"
    mkdir -p "$HOME/Downloads"
    if ! curl -sS -f -L -o "$HOME/Downloads/Miniconda3.sh" "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-$(uname -m).sh"; then
        echo -e "${C_RED}   ↳ Error: Failed to download Miniconda.${C_RESET}"
        exit 1
    fi
    echo "   ↳ Installing Miniconda (1-2 minutes)..."
    bash "$HOME/Downloads/Miniconda3.sh" -b -p "$HOME/miniconda3" >> "$SETUP_LOG" 2>&1
else
    echo -e "${C_CYAN}[2/6] Miniconda ready.${C_RESET}"
fi

echo -e "${C_CYAN}[3/6] Initializing Conda...${C_RESET}"
source "$HOME/miniconda3/etc/profile.d/conda.sh"

if conda env list | grep -Eq '^[[:space:]]*orange3[[:space:]]'; then
    echo -e "${C_YELLOW}   ↳ Existing 'orange3' environment detected. Cleaning up...${C_RESET}"
    conda deactivate 2>/dev/null
    run_cmd conda env remove --name orange3 --yes
fi

echo -e "${C_CYAN}[4/6] Creating Orange3 environment and downloading core packages...${C_RESET}"
echo "      ☕ Please wait. This step takes 10-30 minutes."
echo "      The screen will remain quiet while it works."

run_cmd conda create --name orange3 --channel conda-forge --override-channels python=3.11 pip orange3 $ADDONS_CONDA --yes $QUIET_FLAG

echo -e "${C_CYAN}[5/6] Processing course add-ons...${C_RESET}"
conda activate orange3
run_cmd python -m pip install --upgrade --prefer-binary $QUIET_FLAG $ADDONS_PIP

echo "   ↳ Verifying installation..."
if ! python -c "import Orange" 2>/dev/null; then
    echo -e "${C_RED}   ↳ Error: Orange3 failed to install correctly. Send log to instructor.${C_RESET}"
    exit 1
fi

echo -e "${C_CYAN}[6/6] Building native Desktop application launcher...${C_RESET}"
mkdir -p "$APP_DIR"
rm -f "$HOME/Desktop/launch_orange.command"
rm -rf "$APP_PATH"
rm -rf "$HOME/Desktop/Orange3.app"

osacompile -e "do shell script \"bash -c 'source $HOME/miniconda3/etc/profile.d/conda.sh && conda activate orange3 && python -m Orange.canvas >> $SETUP_LOG 2>&1 &'\"" -o "$APP_PATH" >> "$SETUP_LOG" 2>&1

echo "   ↳ Applying custom Orange icon..."
ICNS_PATH="$APP_PATH/Contents/Resources/applet.icns"
ICNS_URL="https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/orange.icns"

if curl -sS -f -L "$ICNS_URL" -o "$ICNS_PATH" && [ -s "$ICNS_PATH" ]; then
    xattr -cr "$APP_PATH" 2>/dev/null
    touch "$APP_PATH/Contents/Info.plist"
    touch "$APP_PATH"
    killall Finder 2>/dev/null
    echo -e "${C_GREEN}   ↳ Custom icon applied successfully!${C_RESET}"
else
    echo -e "${C_YELLOW}   ↳ Note: Custom icon download skipped. Default app icon assigned.${C_RESET}"
fi

echo ""
echo -e "${C_GREEN}${C_BOLD}==================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}         🎉 SETUP VERIFIED AND COMPLETE!          ${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}==================================================${C_RESET}"
echo "An app named 'Orange3' is now installed in your Applications folder."
echo ""
echo -e "${C_YELLOW}💡 IMPORTANT LAUNCH INSTRUCTIONS:${C_RESET}"
echo " 1. Press Command + Space, type 'Orange3', and press Return."
echo " 2. The first launch may take 30-60 seconds to open."
echo " 3. Do not quit the app or double-click it repeatedly—simply wait."
echo " 4. No Terminal window will pop up—this is normal!"
echo -e "${C_GREEN}==================================================${C_RESET}"