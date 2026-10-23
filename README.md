# JuiceIt 🍊 — Automated Orange3 Setup for macOS
> **Note:** This is an unofficial class‑project script! – not endorsed by Orange or Anaconda. Project purpose was made to simplify Orange3 installations for Macs.

## Table of Contents
- [Before you begin](#before-you-begin)
- [Installation (single step)](#installation-single-step)
- [Launching Orange](#launching-orange)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)

## Before you begin
- Connect to power & a stable internet connection.
- Expect 10-20 min for a full install.
- **Do not** download or install anything manually; the script does it all.
- The installer runs `conda tos accept` automatically.

## Installation (single step)
Run the command below (you can re‑run it safely if interrupted):
```bash
curl -fsSL https://raw.githubusercontent.com/chunw4h/juiceit/refs/heads/main/install_orange.sh | bash
```

## Launching Orange
Open Spotlight (⌘ Space), type Orange3, and press Return.
The first launch may take 30–60s.

Terminal alternative:


```bash

source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda activate orange3
python -m Orange.canvas
```

## Troubleshooting
Installation appears frozen – wait up to 30 min. If still stuck, run:


```bash
tail -n 30 "$HOME/Library/Logs/Orange3_Course_setup.log"
```
and share the output with your instructor.

**Add‑ons missing** – close Orange, relaunch via Spotlight.

**Environment broken** – re‑run with --reset.

## Uninstallation (end of semester)
You can remove everything the installer created in two ways:

1. **Recommended** – run the provided helper script (asks for confirmation, handles all clean‑up automatically):
   ```bash
   curl https://raw.githubusercontent.com/chunw4h/juiceit/refs/heads/main/uninstall_orange.sh
   ```
   Add `--force` to skip the prompts:
   ```bash
   curl https://raw.githubusercontent.com/chunw4h/juiceit/refs/heads/main/uninstall_orange.sh --force
   ```

2. **Manual** – the original steps (kept for reference):
   - Delete the Desktop shortcut.
   - Delete `~/Applications/Orange3.app`.
   - Remove the sandbox Miniconda folder: `rm -rf "$HOME/miniconda3"` (or use Finder).
   - Optional: delete any `miniconda3.backup.*` folders.
