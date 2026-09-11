#!/bin/bash

echo "Starting Orange3 Automated Setup..."

# 1. Check current installation and backup if incomplete
if [ -x "$HOME/miniconda3/bin/conda" ]; then
    echo "Miniconda already installed. Skipping to environment setup."
elif [ -d "$HOME/miniconda3" ]; then
    echo "Incomplete installation found. Backing up..."
    mv "$HOME/miniconda3" "$HOME/miniconda3_backup_$(date +%Y%m%d_%H%M%S)"
fi

# 2. Download and Install Miniconda (if missing)
if [ ! -x "$HOME/miniconda3/bin/conda" ]; then
    echo "Downloading Miniconda for $(uname -m)..."
    cd ~/Downloads
    curl -L -o Miniconda3.sh "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-$(uname -m).sh"

    echo "Installing Miniconda silently..."
    bash Miniconda3.sh -b -p "$HOME/miniconda3"
fi

# 3. Load Miniconda
echo "Sourcing Conda..."
source "$HOME/miniconda3/etc/profile.d/conda.sh"

# 3.5. Environment Cleanup (The "Safe Reset")
echo "Checking for existing orange3 environment..."
if conda env list | grep -q "^orange3 "; then
    echo "Existing 'orange3' environment detected. Cleaning up for a fresh install..."
    conda deactivate 2>/dev/null
    conda env remove --name orange3 --yes
    echo "Old environment removed successfully."
fi

# 4. Create Orange Environment
echo "Creating Orange3 environment (This may take 10-30 minutes, please wait)..."
conda create --name orange3 --channel conda-forge --override-channels python=3.11 pip orange3 orange3-imageanalytics --yes

# 5. Activate and install remaining add-ons
echo "Activating environment and installing add-ons via pip..."
conda activate orange3
python -m pip install --upgrade --prefer-binary Orange3-Text Orange3-Timeseries Orange3-Geo Orange3-Associate

# 6. Generate the Desktop Launcher
echo "Creating desktop launcher..."
LAUNCHER="$HOME/Desktop/launch_orange.command"
echo '#!/bin/bash' > "$LAUNCHER"
echo 'source "$HOME/miniconda3/etc/profile.d/conda.sh"' >> "$LAUNCHER"
echo 'conda activate orange3' >> "$LAUNCHER"
echo 'python -m Orange.canvas' >> "$LAUNCHER"
chmod +x "$LAUNCHER"

echo "=================================================="
echo "Setup complete! "
echo "To start Orange, just double-click 'launch_orange.command' on your Desktop."
echo "=================================================="
