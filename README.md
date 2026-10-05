# JuiceIt 🍊 — Automated Orange3 Setup for macOS

> Note: A self-assigned mini-project for usage in ITM 325 - AI for Business I only!
> Created with the assistance of an LLM. This is by no means official nor endorsed
> nor affiliated with Orange and/or Anaconda.

This repository provides a one-step automated installation script for Orange3 and all required course add-ons (**Text, Time Series, Geo, Image Analytics, and Associate**). The script automatically handles architecture detection for both Intel and Apple Silicon (M-series) Macs. It installs a course-specific copy of Miniconda at `~/miniconda3`, builds an isolated `orange3` environment, and creates a native "Orange3" launcher you can open from Spotlight. It does **not** touch other Anaconda installations on your Mac.

The installation is sourced from 🐍 Anaconda Docs & 🍊 Orange Docs:
* https://orangedatamining.com/download/#:~:text=Other%20platforms-,Anaconda,-Create%20and%20activate
* https://www.anaconda.com/docs/getting-started/miniconda/install/mac-cli-install

## ❗️ Before You Begin

* Connect your Mac to power and a stable internet connection.
* Be prepared to wait; the entire process may take 20–40 minutes, and some steps are quiet for several minutes.
* Do not manually download or reinstall anything beforehand — the script handles everything for you.
* **Heads-up:** Miniconda is installed in silent batch mode, which automatically accepts the Anaconda license terms on your behalf.
* The script also accepts conda's channel Terms of Service (conda tos accept) for Anaconda's default repositories, which recent Miniconda versions require for routine commands. The course environment itself uses only the community conda-forge channel.

## ⚙️ Installation (Single Step)

Open Terminal (press ⌘ Command + Space, type "Terminal", and press Return), then copy and paste the single command below and press Return:
```bash
curl -fsSL https://raw.githubusercontent.com/chunw4h/juiceit/refs/heads/main/install_orange.sh | bash
```
If the install is interrupted midway, you can safely run the exact same command again — it will pick up where it left off and reuse any healthy installation.
To force a full rebuild of the course environment instead, add the `-reset` flag (see below).

### Options

| Command | What it does |
|---|---|
| `... \| bash` | Standard install (default) |
| `... \| bash -s -- --reset` | Delete and rebuild the `orange3` environment from scratch |
| `... \| bash -s -- --verbose` | Show live command output instead of only logging it |

## 🚀 Launching Orange

Once setup completes, a launch log will appear in `~/Applications/Orange3.app`.

1. Press ⌘ Command + Space, type `Orange3`, and press Return.
2. The first launch may take 30–60 seconds. Be patient and wait.
3. No Terminal window will appear — that is normal.

**Terminal alternative:**

```bash
source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda activate orange3
python -m Orange.canvas
```

## 🔎 Troubleshooting

**The installation looks frozen:** Wait up to 30 minutes. By default, command output is written to a log rather than Terminal. If there is still no progress, copy the last 20–30 lines of the setup log and send them to your instructor (or an LLM of your preferred choice):

```bash
tail -n 30 "$HOME/Library/Logs/Orange3_Course_setup.log"
```

**Orange opens, but add-ons are missing.** Close Orange and launch it again via Spotlight (⌘ Command + Space → `Orange3`). Using old paths or older Anaconda installations will cause Orange to open without the course add-ons.

**The environment seems broken.** Re-run the install command with `--reset`:

```bash
curl -fsSL https://raw.githubusercontent.com/chunw4h/juiceit/refs/heads/main/install_orange.sh | bash -s -- --reset
```

**A different error appears.** Do not delete system folders or reinstall macOS. Copy the last 20–30 log lines (command above) so the exact error can be checked.

## 🏁 Uninstallation (End of Semester)

Because this setup creates an isolated course copy of Miniconda at `~/miniconda3`, it does not interfere with your system files or other Anaconda installations. Orange workflows you saved elsewhere are not affected.

To completely remove Orange and free up disk space, delete these two items:

1. In Finder, go to your **Applications folder inside your home directory**
   (`Macintosh HD > Users > your-name > Applications`) and delete `Orange3.app`.
2. Open Finder, go to your home folder, and delete the `miniconda3` folder.
   (You can also use Terminal: `rm -rf "$HOME/miniconda3"`)

Optional cleanup: if an earlier install was interrupted, you may also have a `miniconda3.backup.<date>` folder in your home directory — those can be deleted too.
> Written with [StackEdit](https://stackedit.io/).
