# Orange3 Automated Setup: Project Roadmap

This roadmap outlines the development phases for the Orange3 Automated Setup utility. Our primary goal is to completely eliminate environment configuration friction for students, allowing them to focus on data mining rather than system administration.

## Phase 1: Automation (Completed)
- [x] **Architecture Agnosticism:** Dynamic detection for Apple Silicon (arm64) and Intel (x86_64) processors to fetch the correct Miniconda installers.
- [x] **Course Isolation:** Sandbox Miniconda inside `$HOME/miniconda3` to prevent conflicts with students' existing Python or standard Anaconda installations.
- [x] **Dependency Routing:** Automate the split-installation workaround (Conda for core packages, Pip for specific add-ons) to bypass Apple Silicon compilation errors.
- [x] **Idempotent Resetting:** Build safe-reset logic that automatically detects and clears corrupted `orange3` environments if a user re-runs the script.

## Phase 2: UX & Added Polish (Completed)
- [x] **Native macOS Integration:** Replace terminal `.command` scripts with compiled, native `.app` application bundles deployed directly to the `~/Applications` folder.
- [x] **Custom Branding:** Automatically fetch and apply course-specific `.icns` branding to the application bundle.
- [x] **Silent Execution:** Reroute verbose compilation and package-solving output to a dedicated background log file (`~/Library/Logs/Orange3_Course.log`).
- [x] **Deployment Options:** Provide both an Express (one-liner) and Interactive (custom add-on selection) installation path.
- [x] **UI Enhancements:** Implement ANSI color-coded terminal interfaces for clear readability and status tracking.

## Phase 3: Reliability & Maintenance (Next Up)
- [ ] **Automated Uninstaller:** Create a standalone `uninstall_orange.sh` script to cleanly remove the application bundle, the Miniconda directory, and all associated logs at the end of the semester.
- [ ] **Pre-Flight Disk Checks:** Add logic to verify the user has the required ~3-5GB of free disk space before attempting to download Miniconda and Conda packages.
- [ ] **One-Click Updater:** Develop an `update_orange.sh` script to upgrade Orange and course add-ons to their latest versions without requiring a full environment teardown.
- [ ] **Network Resilience:** Implement retry-loops for `curl` downloads to handle spotty campus Wi-Fi connections gracefully.

## Phase 4: Course Integration & Expansion (Future)
- [ ] **Windows Parity:** Develop a translated PowerShell (`.ps1`) equivalent of the Express installer for Windows users.
- [ ] **Automated Dataset Fetching:** Add an interactive prompt to automatically download course-required datasets (e.g., CSVs or Excel files) directly to a dedicated folder on the student's Desktop.
- [ ] **Diagnostic Tooling:** Build a lightweight diagnostic script that automatically gathers Conda environment details, macOS version, and installation logs into a single `.zip` file for easy instructor troubleshooting.