# 6. Generate the Desktop App Launcher
echo "Creating native desktop app launcher..."
APP_PATH="$HOME/Desktop/Orange3.app"

# Remove the old .command file if it exists
if [ -f "$HOME/Desktop/launch_orange.command" ]; then
    rm "$HOME/Desktop/launch_orange.command"
fi

# Use osacompile to create a real macOS application bundle
osacompile -e 'do shell script "bash -c '\''source ~/miniconda3/etc/profile.d/conda.sh && conda activate orange3 && python -m Orange.canvas >/dev/null 2>&1 &'\''"' -o "$APP_PATH"

echo "=================================================="
echo "Setup complete!"
echo "To start Orange, just double-click 'Orange3.app' on your Desktop."
echo "=================================================="

## Created with assistance from Gemini 3.1 Pro
