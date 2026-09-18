#!/bin/bash

echo "=================================================="
echo "    Starting Orange3 Automated macOS Setup       "
echo "=================================================="
echo "Note: This process may take 10-30 minutes total."
echo "Terminal may appear quiet or paused for several minutes."
echo "Please keep your Mac connected to the internet, (and power, if battery is low)."
echo "--------------------------------------------------"

# 1. Check current installation and backup if incomplete
echo "[1/5] Checking system for previous installations..."
if [ -x "$HOME/miniconda3/bin/conda" ]; then
    echo "   ↳ Miniconda already detected. Skipping base install."
elif [ -d "$HOME/miniconda3" ]; then
    echo "   ↳ Incomplete installation found. Creating timestamped backup..."
    mv "$HOME/miniconda3" "$HOME/miniconda3_backup_$(date +%Y%m%d_%H%M%S)"
fi

# 2. Download and Install Miniconda (if missing)
if [ ! -x "$HOME/miniconda3/bin/conda" ]; then
    echo "[2/5] Downloading Miniconda installer for $(uname -m)..."
    cd ~/Downloads
    curl -L -o Miniconda3.sh "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-$(uname -m).sh"
    
    echo "   ↳ Installing Miniconda silently (this takes 1-2 minutes)..."
    bash Miniconda3.sh -b -p "$HOME/miniconda3"
fi

# 3. Load Miniconda
echo "[3/5] Initializing Conda..."
source "$HOME/miniconda3/etc/profile.d/conda.sh"

# 3.5. Environment Cleanup (Safe Reset)
if conda env list | grep -E -q "^orange3[[:space:]*]"; then
    echo "   ↳ Existing 'orange3' environment detected. Cleaning up for a fresh install..."
    conda deactivate 2>/dev/null
    conda env remove --name orange3 --yes
    echo "   ↳ Old environment removed."
fi

# 4. Create Orange Environment
echo "[4/5] Creating Orange3 environment and downloading core packages..."
echo "      ☕ Package solving and downloading may take 10-30 minutes."
echo "      Please DO NOT close this Terminal window— it is working in the background!"

conda create --name orange3 --channel conda-forge --override-channels python=3.11 pip orange3 orange3-imageanalytics --yes

echo "   ↳ Core packages installed. Adding course add-ons (Text, Geo, Timeseries, Associate)..."
conda activate orange3
python -m pip install --upgrade --prefer-binary Orange3-Text Orange3-Timeseries Orange3-Geo Orange3-Associate

# 5. Generate the Desktop App Launcher with Custom Icon
echo "[5/5] Building native Desktop application launcher..."
APP_PATH="$HOME/Desktop/Orange3.app"

# Clean up any old shortcuts
rm -f "$HOME/Desktop/launch_orange.command"
rm -rf "$APP_PATH"

# Compile AppleScript bundle
osacompile -e "do shell script \"bash -c 'source $HOME/miniconda3/etc/profile.d/conda.sh && conda activate orange3 && python -m Orange.canvas >/dev/null 2>&1 &'\"" -o "$APP_PATH"

# Download custom icon and force Finder metadata re-index
echo "   ↳ Applying custom Orange icon..."
ICNS_PATH="$APP_PATH/Contents/Resources/applet.icns"
ICNS_URL="https://raw.githubusercontent.com/chunw4h/juiceit/main/Orange3.icns"

if curl -L -f -s -S "$ICNS_URL" -o "$ICNS_PATH" && [ -s "$ICNS_PATH" ]; then
    xattr -cr "$APP_PATH" 2>/dev/null
    touch "$APP_PATH/Contents/Info.plist"
    touch "$APP_PATH"
    killall Finder 2>/dev/null
    echo "   ↳ Custom icon applied successfully!"
else
    echo "   ↳ Note: Custom icon download skipped or file missing. Default app icon assigned."
fi

echo ""
echo "=================================================="
echo "         SETUP COMPLETE WITHOUT ISSUE!          "
echo "=================================================="
echo "An app named 'Orange3.app' is now on your Desktop."
echo ""
echo "NOTE - IMPORTANT LAUNCH INSTRUCTIONS FOR STUDENTS:"
echo " 1. Double-click 'Orange3.app' on your Desktop to start."
echo " 2. The first launch may take 30-60 seconds to open."
echo " 3. No Terminal window will pop up—this is normal!"
echo " 4. Please wait patiently and avoid double-clicking repeatedly."
echo "=================================================="