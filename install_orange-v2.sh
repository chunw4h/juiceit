#!/bin/bash
#
echo "Orange3 Automated Setup for macOS (ITM 325) — merged version"
#
echo "Usage: "
echo "bash install_orange.sh              Normal setup. Reuses an existing healthy env."
echo "bash install_orange.sh --reset      Delete the orange3 env first, then rebuild."
echo "bash install_orange.sh --verbose    Show live command output (also logged)."
echo "bash install_orange.sh --help"
#
echo Requires: macOS, internet, ~30 minutes.
#

set -u
set -o pipefail

# --- 0. Configuration --------------------------------------------------------
ENV_NAME="orange3"
MINICONDA="$HOME/miniconda3"
CONDA_SH="$MINICONDA/etc/profile.d/conda.sh"
SETUP_LOG="$HOME/Library/Logs/Orange3_Course_setup.log"
LAUNCH_LOG="$HOME/Library/Logs/Orange3_Course_launch.log"
APP_DIR="$HOME/Applications"
APP_PATH="$APP_DIR/Orange3.app"

VERBOSE=0
RESET_ENV=0

C_RESET='\033[0m'; C_CYAN='\033[0;36m'; C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'; C_RED='\033[0;31m'; C_BOLD='\033[1m'

usage() {
    cat <<'EOF'
Usage: bash install_orange.sh [--reset] [--verbose]

  (default)   Set up Orange3; reuses an existing healthy environment.
  --reset     Delete the orange3 environment first, then rebuild it.
  --verbose   Print command output live instead of only logging it.
EOF
    exit 0
}

fail() {
    echo ""
    echo -e "${C_RED}ERROR: $1${C_RESET}"
    echo "Technical log: $SETUP_LOG"
    echo "Screenshot the last 20-30 log lines and send them to the instructor."
    echo "Do not delete system folders or reinstall macOS."
    exit 1
}

step() { echo -e "${C_CYAN}${C_BOLD}[$1/6] $2${C_RESET}"; }
ok()   { echo -e "   ${C_GREEN}[OK]${C_RESET} $1"; }

# Run a command, log it, and PROPAGATE its exit code (caller must || fail).
run_cmd() {
    echo "[cmd] $*" >> "$SETUP_LOG"
    if [ "$VERBOSE" = 1 ]; then
        "$@" 2>&1 | tee -a "$SETUP_LOG"
        return "${PIPESTATUS[0]}"
    fi
    "$@" >> "$SETUP_LOG" 2>&1
}

# Escape a string for embedding inside an AppleScript "..." literal
applescript_escape() {
    local s="$1"
    s="${s//\\/\\\\}"   # backslash first
    s="${s//\"/\\\"}"   # then double quotes
    printf '%s' "$s"
}

# --- Flag parsing ------------------------------------------------------------
for arg in "$@"; do
    case "$arg" in
        --verbose) VERBOSE=1 ;;
        --reset)   RESET_ENV=1 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $arg" >&2; usage ;;
    esac
done

# --- Log setup ----------------------------------------------------------------
mkdir -p "${SETUP_LOG%/*}" || fail "Cannot create log directory."

clear
echo -e "${C_CYAN}${C_BOLD}==================================================${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}     Orange3 Automated macOS Setup (ITM 325)     ${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}==================================================${C_RESET}"
echo "Detailed log: $SETUP_LOG"
echo "--------------------------------------------------"
echo "Orange3 Installation Log — $(date)" > "$SETUP_LOG"

# --- [1/6] System check -------------------------------------------------------
step 1 "Checking system for previous installations..."
[ "$(uname -s)" = "Darwin" ] || fail "This script must be run on macOS."

RESULT="C"
if [ -x "$MINICONDA/bin/conda" ]; then
    RESULT="A"
    echo "   -> Miniconda already installed. Keeping it."
elif [ -d "$MINICONDA" ]; then
    RESULT="B"
    echo "   -> Incomplete installation found. Backing it up..."
    mv "$MINICONDA" "$MINICONDA.backup.$(date +%Y%m%d_%H%M%S)" >> "$SETUP_LOG" 2>&1 \
        || fail "Could not back up the incomplete miniconda3 folder."
    RESULT="C"
fi

# --- [2/6] Miniconda (unattended batch install) --------------------------------
if [ "$RESULT" = "C" ]; then
    step 2 "Installing Miniconda for $(uname -m)..."
    ARCH="$(uname -m)"
    case "$ARCH" in arm64|x86_64) ;; *) fail "Unsupported architecture: $ARCH" ;; esac

    INSTALLER="$HOME/Downloads/Miniconda3-latest-MacOSX-$ARCH.sh"
    curl -fL --retry 3 -o "$INSTALLER" \
        "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-$ARCH.sh" \
        || fail "Download failed. Check your internet connection and re-run."
    [ -s "$INSTALLER" ] || fail "Downloaded installer is empty."

    echo "   -> Running silent installer (1-2 minutes)."
    echo "      Note: batch mode auto-accepts the Anaconda license terms."
    bash "$INSTALLER" -b -p "$MINICONDA" >> "$SETUP_LOG" 2>&1 \
        || fail "Miniconda installation failed. See log."
    [ -x "$MINICONDA/bin/conda" ] || fail "Miniconda not found after install. See log."
    ok "Miniconda installed to $MINICONDA"
else
    step 2 "Miniconda ready (skipping installation)."
fi

# --- [3/6] Initialize Conda ----------------------------------------------------
step 3 "Initializing Conda..."
source "$CONDA_SH" || fail "Cannot load $CONDA_SH."
conda --version || fail "conda command failed after sourcing."

CONDA_BASE="$(conda info --base)" || fail "conda info --base failed."
[ "$CONDA_BASE" = "$MINICONDA" ] \
    || fail "conda base is '$CONDA_BASE', expected '$MINICONDA'. Do not use /opt/anaconda3."
ok "Conda $(conda --version 2>/dev/null | awk '{print $2}') at $CONDA_BASE"

# --- [4/6] Environment (idempotent; --reset to force rebuild) -------------------
step 4 "Preparing the '$ENV_NAME' environment..."

if [ "$RESET_ENV" = 1 ] && [ -d "$MINICONDA/envs/$ENV_NAME" ]; then
    echo "   -> --reset given: removing existing environment..."
    run_cmd conda env remove --name "$ENV_NAME" --yes \
        || fail "Could not remove the old environment. See log."
fi

if [ -d "$MINICONDA/envs/$ENV_NAME" ]; then
    echo "   -> Existing environment detected — reusing it (no rebuild)."
    echo "      (Run with --reset to rebuild from scratch.)"
else
    echo "   -> Creating environment + core packages. This takes 10-30 minutes."
    echo "      The screen will stay quiet; progress is written to the log."
    if [ "$VERBOSE" = 1 ]; then
        run_cmd conda create --name "$ENV_NAME" \
            --channel conda-forge --override-channels \
            python=3.11 pip orange3 orange3-imageanalytics --yes \
            || fail "conda create failed. See Troubleshooting: 'LibMambaUnsatisfiableError'."
    else
        run_cmd conda create --name "$ENV_NAME" \
            --channel conda-forge --override-channels \
            python=3.11 pip orange3 orange3-imageanalytics --yes --quiet \
            || fail "conda create failed. See Troubleshooting: 'LibMambaUnsatisfiableError'."
    fi
    ok "Environment created"
fi

# --- [5/6] Add-ons via pip + full verification ----------------------------------
step 5 "Installing course add-ons (Text, Time Series, Geo, Associate)..."
conda activate "$ENV_NAME" || fail "Could not activate '$ENV_NAME'."
[ "${CONDA_DEFAULT_ENV:-}" = "$ENV_NAME" ] || fail "Activation did not complete."

# pip (not conda) per the guide — avoids the Apple Silicon ufal.udpipe / lemmagen3 error
if [ "$VERBOSE" = 1 ]; then
    run_cmd python -m pip install --upgrade --prefer-binary \
        Orange3-Text Orange3-Timeseries Orange3-Geo Orange3-Associate \
        || fail "pip install failed. If the env seems broken, re-run with --reset."
else
    run_cmd python -m pip install --upgrade --prefer-binary --quiet \
        Orange3-Text Orange3-Timeseries Orange3-Geo Orange3-Associate \
        || fail "pip install failed. If the env seems broken, re-run with --reset."
fi

echo "   -> Verifying Orange core + all 5 course add-ons..."
python - <<'PY' || fail "Verification failed — components missing. Re-run with --reset."
import importlib.util
checks = [
    ("Orange core",      "Orange"),
    ("Text",             "orangecontrib.text"),
    ("Time Series",      "orangecontrib.timeseries"),
    ("Geo",              "orangecontrib.geo"),
    ("Image Analytics",  "orangecontrib.imageanalytics"),
    ("Associate",        "orangecontrib.associate"),
]
missing = [label for label, mod in checks if importlib.util.find_spec(mod) is None]
if missing:
    print("MISSING: " + ", ".join(missing))
    raise SystemExit(1)
print("Verified: Orange core + all 5 course add-ons.")
PY
ok "Installation verified"

# --- [6/6] Native .app launcher --------------------------------------------------
step 6 "Building the 'Orange3' app launcher..."
mkdir -p "$APP_DIR" || fail "Cannot create $APP_DIR."
rm -rf "$APP_PATH"   # replace only our own generated app

INNER="source \"$CONDA_SH\" && conda activate $ENV_NAME && python -m Orange.canvas >> \"$LAUNCH_LOG\" 2>&1 &"
osacompile -e "do shell script \"$(applescript_escape "$INNER")\"" -o "$APP_PATH" \
    >> "$SETUP_LOG" 2>&1 || fail "Could not build the Orange3 app (osacompile failed). See log."
[ -d "$APP_PATH/Contents" ] || fail "Orange3.app was not created correctly. See log."

# Register with LaunchServices so Spotlight finds it (best-effort)
LSREG="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [ -x "$LSREG" ]; then
    "$LSREG" -f "$APP_PATH" >> "$SETUP_LOG" 2>&1
fi
touch "$APP_PATH"
ok "Created $APP_PATH (default macOS icon; Orange's own logo loads at first launch)"

# --- Done -------------------------------------------------------------------------
echo ""
echo -e "${C_GREEN}${C_BOLD}==================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}       SETUP COMPLETE AND VERIFIED (6/6)         ${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}==================================================${C_RESET}"
echo ""
echo -e "${C_YELLOW}LAUNCH INSTRUCTIONS:${C_RESET}"
echo "  1. Press Command + Space, type 'Orange3', press Return."
echo "  2. First launch may take 30-60 seconds. Launch once and wait."
echo "  3. No Terminal window will appear — that is normal."
echo ""
echo "  Terminal alternative (Part C of the guide):"
echo "    source \"$CONDA_SH\""
echo "    conda activate $ENV_NAME"
echo "    python -m Orange.canvas"
echo ""
echo "  Installed add-ons: Text, Time Series, Geo, Image Analytics, Associate"
echo "  Orange runtime log: $LAUNCH_LOG"
echo "  Setup log:          $SETUP_LOG"