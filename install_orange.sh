#!/bin/bash

# Define where all the messy installation text will go
SETUP_LOG="$HOME/Library/Logs/Orange3_Course.log"
APP_PATH="$HOME/Desktop/Orange3.app"

clear

echo "=================================================="
echo "    Starting Orange3 Automated macOS Setup       "
echo "=================================================="
echo "Note: This process may take 20-40 minutes total."
echo "Terminal will stay completely quiet during steps."
echo "Please keep your Mac connected to power and internet."
echo "--------------------------------------------------"
echo "A detailed technical log is being saved to:"
echo "$SETUP_LOG"
echo "--------------------------------------------------"

# Initialize log file
echo "Orange3 Installation Log - $(date)" > "$SETUP_LOG"

# 1. Check current installation and backup if incomplete
echo "[1/6] Checking system for previous installations..."
if [ -x "$HOME/miniconda3/bin/conda" ]; then
    echo "   ↳ Miniconda already detected. Skipping base install."
elif [ -d "$HOME/miniconda3" ]; then
    echo "   ↳ Incomplete installation found. Creating timestamped backup..."
    mv "$HOME/miniconda3" "$HOME/miniconda3_backup_$(date +%Y%m%d_%H%M%S)" >> "$SETUP_LOG" 2>&1
fi

# 2. Download and Install Miniconda
if [ ! -x "$HOME/miniconda3/bin/conda" ]; then
    echo "[2/6] Downloading Miniconda installer for $(uname -m)..."
    mkdir -p "$HOME/Downloads"
    
    # -sS makes curl silent but still outputs critical errors
    if ! curl -sS -f -L -o "$HOME/Downloads/Miniconda3.sh" "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-$(uname -m).sh"; then
        echo "   ↳ Error: Failed to download Miniconda. Check your internet connection."
        exit 1
    fi
    
    echo "   ↳ Installing Miniconda silently (this takes 1-2 minutes)..."
    bash "$HOME/Downloads/Miniconda3.sh" -b -p "$HOME/miniconda3" >> "$SETUP_LOG" 2>&1
fi

# 3. Load Miniconda
echo "[3/6] Initializing Conda..."
source "$HOME/miniconda3/etc/profile.d/conda.sh"

# 3.5. Environment Cleanup 
if conda env list | grep -Eq '^[[:space:]]*orange3[[:space:]]'; then
    echo "   ↳ Existing 'orange3' environment detected. Cleaning up..."
    conda deactivate 2>/dev/null
    conda env remove --name orange3 --yes >> "$SETUP_LOG" 2>&1
    echo "   ↳ Old environment safely removed."
fi

# 4. Create Orange Environment (Conda for Core)
echo "[4/6] Creating Orange3 environment and downloading core packages..."
echo "      ☕ Please wait. This step takes 10-30 minutes."
echo "      The screen will not change while it works in the background."

conda create --name orange3 --channel conda-forge --override-channels python=3.11 pip orange3 orange3-imageanalytics --yes --quiet >> "$SETUP_LOG" 2>&1

# 5. Add Course Add-ons (Pip required for Apple Silicon workaround)
echo "[5/6] Core packages installed. Adding course add-ons via pip..."
conda activate orange3
python -m pip install --upgrade --prefer-binary --quiet Orange3-Text Orange3-Timeseries Orange3-Geo Orange3-Associate >> "$SETUP_LOG" 2>&1

# Verify installation before building the launcher
echo "   ↳ Verifying installation..."
if ! python -c "import Orange" 2>/dev/null; then
    echo "   ↳ Error: Orange3 failed to install correctly."
    echo "   ↳ Please send the log file to your instructor: $SETUP_LOG"
    exit 1
fi

# 6. Generate the Desktop App Launcher with Custom Icon
echo "[6/6] Building native Desktop application launcher..."

rm -f "$HOME/Desktop/launch_orange.command"
rm -rf "$APP_PATH"

# Compiling launcher (Now routing runtime errors to the same log file)
osacompile -e "do shell script \"bash -c 'source $HOME/miniconda3/etc/profile.d/conda.sh && conda activate orange3 && python -m Orange.canvas >> $SETUP_LOG 2>&1 &'\"" -o "$APP_PATH" >> "$SETUP_LOG" 2>&1

echo "   ↳ Applying custom Orange icon..."
ICNS_PATH="$APP_PATH/Contents/Resources/applet.icns"
ICNS_URL="https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/orange.icns"

if curl -sS -f -L "$ICNS_URL" -o "$ICNS_PATH" && [ -s "$ICNS_PATH" ]; then
    xattr -cr "$APP_PATH" 2>/dev/null
    touch "$APP_PATH/Contents/Info.plist"
    touch "$APP_PATH"
    killall Finder 2>/dev/null
    echo "   ↳ Custom icon applied successfully!"
else
    echo "   ↳ Note: Custom icon download skipped. Default app icon assigned."
fi

echo ""
echo "=================================================="
echo "         🎉 SETUP VERIFIED AND COMPLETE!          "
echo "=================================================="
echo "An app named 'Orange3.app' is now on your Desktop."
echo ""
echo "💡 IMPORTANT LAUNCH INSTRUCTIONS:"
echo " 1. Double-click 'Orange3.app' on your Desktop to start."
echo " 2. The first launch may take 30-60 seconds to open."
echo " 3. Do not quit the app or double-click it repeatedly—simply wait a little."
echo " 4. No Terminal window will pop up—this is normal!"
echo "=================================================="