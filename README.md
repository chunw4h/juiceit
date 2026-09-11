# JuiceIt - An automated set-up and install script for Orange Data Mining on macOS.
A simple auto-install script for Orange Data Mining software. Installation and set-up automated for ease-of-use. A self-assigned mini-project for course usage in ITM-325 only!

## Orange3 macOS Automated Setup
This repository provides a one-step automated installation script for Orange3 and its required course add-ons. The script automatically handles architecture detection for both Intel and Apple Silicon (M-series) Macs. It installs a course-specific copy of Miniconda, configures the environment, and generates a convenient Desktop launcher.

## Before You Begin
* If available, connect your Mac to power. If not, make sure your Mac is above 50%; also, you will need a stable internet connection.
* Be prepared to wait; the entire process could* take 20-40 minutes.
* Do not begin by downloading or reinstalling anything manually before running this script.

## Installation (One-Step)
To install Orange3, open the **Terminal** application (press Command + Space, type "Terminal", and press Return). Copy and paste the single command below into Terminal, then press Return:

`curl -fsSL https://github.com/chunw4h/juiceit/blob/be9e43eefcaaef68ac4da1934f04007d712814a2/install_orange.sh | bash`

*(Note: If you run into an issue midway or your internet drops, you can safely run this exact same command again to clean up and restart the process.)*

Once the script finishes, a file called `launch_orange.command` will appear on your Desktop. **Double-click this file every time you want to start Orange.**

## Troubleshooting
* **The installation looks frozen:** Wait up to 30 minutess. Some steps may be quiet for several minutes. If there is still no new output, take a screenshot of the last 20-30 Terminal lines and send it into an LLM.
* **Orange opens, but add-ons are missing:** Close Orange and ensure you are using the new Desktop launcher. Using old paths or older Anaconda installations will cause Orange to open without the course add-ons.
* **A different error appears:** Do not delete system folders or reinstall macOS. Copy or photograph the last 20-30 Terminal lines so the exact error can be checked.
