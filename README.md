# JuiceIt 🍊 - An automated set-up and install script for Orange3 Data Mining on macOS.
A simple auto-install script for Orange Data Mining software. Installation and set-up automated for ease-of-use. 

> Note: A self-assigned mini-project for usage in **ITM 325 - AI for Business I** only! | Created with the assistance of an LLM. 

This is by no means official nor endorsed nor affiliated with Orange and/or Anaconda.

This repository provides a one-step automated installation script for Orange3 and its required course add-ons. The script automatically handles architecture detection for both Intel and Apple Silicon (M-series) Macs. It installs a course-specific copy of Miniconda, configures the environment, and generates a convenient Desktop launcher.

The installation is sourced from 🐍 Anaconda Docs & 🍊 Orange Docs. Please see links here:
* https://orangedatamining.com/download/#:~:text=Other%20platforms-,Anaconda,-Create%20and%20activate
* https://www.anaconda.com/docs/getting-started/miniconda/install/mac-cli-install

## ❗️Before You Begin 
* Ensure that your Mac has sufficient battery available for this set-up. 
* Be prepared to wait; the entire process *may* take 15-30 minutes.
* Do not begin by downloading or reinstalling anything manually before running this script. This will handle the steps for you. 

## ⚙️ Installation (Single Step)
To install Orange3 via Miniconda, open the **Terminal** application (press **⌘ Command + Space**, type "Terminal", and press Return). Copy and paste the single command below into Terminal, then press Return:

```
curl -fsSL https://raw.githubusercontent.com/chunw4h/juiceit/refs/heads/main/install_orange.sh | bash
```
*(Note: If you run into an issue midway or your internet drops, you can safely run this exact same command again to clean up and restart the process.)*

Once the script finishes, a file called `launch_orange.command` will appear on your Desktop. **Double-click this file every time you want to start Orange.**

## 🔎 Troubleshooting
* **The installation looks frozen:** Wait up to 30 minutess. Some steps may be quiet for several minutes. If there is still no new output, take a screenshot of the last 20-30 Terminal lines and send it into an LLM of your preferred choice.
* **Orange opens, but add-ons are missing:** Close Orange and ensure you are using the new Desktop launcher. Using old paths or older Anaconda installations will cause Orange to open without the course add-ons.
* **A different error appears:** Do not delete system folders or reinstall macOS. Copy or photograph the last 20-30 Terminal lines so the exact error can be checked.

## 🏁 Uninstallation (End of Semester)
Because this setup creates an isolated course copy of Miniconda at `$HOME/miniconda3`, it does not interfere with your system files or other Anaconda installations. 

To completely remove Orange and free up disk space at the end of the course, simply delete these two items:
1. Delete the `launch_orange.command` file from your Desktop.
2. Open Finder, go to your home folder (`Macintosh HD > Users > your-name`), and delete the `miniconda3` folder. 
   *(Note: You can also use Terminal by running `rm -rf $HOME/miniconda3`)*
