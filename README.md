# OpenCode Portable (Windows 10 / 11) - v2 Edition

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6.svg)](https://microsoft.com/windows)
[![OpenCode v2](https://img.shields.io/badge/OpenCode-v2.0-8A2BE2.svg)](https://opencode.ai/v2)
[![CI Status](https://img.shields.io/badge/CI-Passing-brightgreen.svg)](#)

**English** | [Español](README.es.md)

A self-contained, zero-host-dependency portable edition of **OpenCode v2** designed specifically for **Windows 10 and 11**. Run OpenCode directly from any USB flash drive or external drive on any machine while completely retaining your configurations, provider credentials, and session history—without leaving traces on or relying on the host computer.

> **Zero Third-Party Mirrors:** Binaries and runtimes are fetched exclusively from official upstream releases: [anomalyco/opencode](https://github.com/anomalyco/opencode) / [opencode.ai](https://opencode.ai), [Git for Windows](https://github.com/git-for-windows/git), and [Node.js](https://nodejs.org).

---

## 🚀 Key Features

* 🔌 **100% Plug & Play USB Portability:** Dynamic relative paths automatically detect the current drive letter (`D:`, `E:`, `F:`, etc.).
* 🛡️ **Total Host Isolation & Data Persistence:**
  * Credentials (`/connect`), conversation sessions, agent configs, and tool states persist safely inside `data/` on the USB drive.
  * Windows user profiles and environment variables (`USERPROFILE`, `HOME`, `APPDATA`, `LOCALAPPDATA`, `TEMP`, `TMP`) are fully redirected.
  * Compliant with XDG Base Directory specification and OpenCode v2 configuration paths (`OPENCODE_CONFIG_DIR`, `OPENCODE_DATA_DIR`, `OPENCODE_CACHE_DIR`, `OPENCODE_STATE_DIR`, `OPENCODE_LOG_DIR`).
  * **Leaves zero traces or temporary junk on the host computer's `C:` drive.**
* 🧰 **Self-Contained Toolchain (Zero Host Prerequisites):**
  * **Official OpenCode v2:** Native 64-bit compiled executable in `bin/opencode.exe`.
  * **Embedded Git Portable:** [MinGit](https://github.com/git-for-windows/git) with Busybox in `tools/git/` for full repository, diff, and Unix command support without requiring Git on the host PC.
  * **Embedded Node.js Portable:** Official Node.js LTS in `tools/node/` ensuring seamless execution of Model Context Protocol (MCP) servers (`npx`, `npm`) and plugins.
* 💻 **Modern Terminal Integration (Zero Character Glitches):**
  * Automatically detects and prioritizes **Windows Terminal (`wt.exe`)** for GPU-accelerated DirectWrite text rendering, true UTF-8 support, and pixel-perfect TUI borders.
  * Falls back to an isolated PowerShell 5.1+ UTF-8 bridge if Windows Terminal is not installed, eliminating legacy CMD encoding defects.
  * OpenCode internal terminal and tool execution defaults to **PowerShell** via `data/config/opencode/opencode.jsonc`.
* 🔄 **One-Click Official Auto-Updater:**
  * Checks for new upstream OpenCode v2 releases directly from official channels.
  * Seamlessly upgrades `bin/opencode.exe` while preserving 100% of your configurations and session history in `data/`.
  * Includes automated backup and rollback protection.


---

## 📁 Directory Structure

```text
opencode-portable/
│
├── opencode.bat                 # Primary launcher (double-click or from CMD / Terminal)
├── opencode.ps1                 # Native launcher for PowerShell
├── update.bat                   # 1-Click updater for OpenCode v2
├── shell.bat                    # Isolated terminal with OpenCode, Git & Node loaded in PATH
│
├── bin/
│   └── opencode.exe             # Official compiled OpenCode v2 binary
│
├── tools/
│   ├── git/                     # Embedded Git Portable (MinGit + Busybox)
│   └── node/                    # Embedded Node.js Portable LTS
│
├── data/                        # 💾 ALL YOUR PORTABLE DATA PERSISTS HERE
│   ├── config/
│   │   ├── opencode/
│   │   │   ├── opencode.example.jsonc # Base configuration template
│   │   │   └── opencode.jsonc   # Your active configuration file
│   │   └── .gitconfig           # Portable Git config
│   ├── share/                   # Conversation history & SQLite databases
│   ├── cache/                   # Cache storage
│   ├── state/                   # Execution state
│   ├── logs/                    # Application logs
│   ├── profile/                 # Isolated USERPROFILE / HOME
│   ├── appdata/                 # Isolated AppData (Roaming & Local)
│   └── temp/                    # Isolated TEMP / TMP
│
└── scripts/
    ├── env.bat                  # Environment variable isolation engine
    ├── setup.ps1                # Automated suite bootstrapper
    ├── update.ps1               # Safe official auto-updater logic
    └── package-release.ps1      # Release packaging utility
```

---

## ⚡ Step-by-Step Quick Start Guide

You don't need any pre-installed software on your computer (no Node.js, Git, or Python required). Everything runs in a self-contained environment directly on your USB drive.

### Step 1: Prepare Your USB Drive

Plug your USB flash drive into any PC running **Windows 10 or 11** (64-bit). We recommend a drive with at least **1–2 GB** of free space.

Choose **either of the two methods** to place the files onto your drive:

#### Option A (Recommended for most users): Download the Official Release ZIP
1. Go to **[GitHub Releases](https://github.com/cgmark101/opencode-portable/releases/latest)**.
2. Download `opencode-portable-windows-x64.zip`.
3. Open your USB drive (e.g. drive `E:\` or `D:\`) and extract the archive there.  
   You will have a folder like `E:\opencode-portable` (or files in the root of the drive).

#### Option B (For developers): Clone with Git
If you have Git installed on your current machine and prefer cloning:
```cmd
cd /d E:\
git clone https://github.com/cgmark101/opencode-portable.git
cd opencode-portable
```

---

### Step 2: First Launch (Automatic Setup)

1. Open the `opencode-portable` folder on your USB flash drive.
2. **Double-click `opencode.bat`** (or in PowerShell: `.\opencode.ps1`).
3. **What happens automatically?**
   * The launcher detects it is the first run on this USB drive.
   * It securely downloads official upstream binaries: **OpenCode v2** (`bin\opencode.exe`), **Git Portable** (`tools\git\`), and **Node.js Portable LTS** (`tools\node\`).
   * It initializes your isolated directory layout inside `data/`.
   * In less than a minute, the OpenCode interactive terminal (TUI) opens on your screen.

---

### Step 3: Connect Your AI Providers

Inside the interactive OpenCode terminal:
1. Type:
   ```text
   /connect
   ```
2. Select your AI provider (OpenAI, Anthropic Claude, Google Gemini, Groq, local Ollama, etc.).
3. Paste your API Key when prompted.
4. **Done!** Your credentials are encrypted and stored safely inside `data/` on your USB drive. **Nothing is ever stored on the host computer's `C:\` drive.**

---

### Step 4: Using on Another Computer (True Plug & Play)

Whenever you want to work on a different computer (at the office, school, or a friend's PC):
1. **Safely eject** the USB drive from your current computer.
2. **Plug it into the new PC**.
3. Open the USB drive and double-click:
   ```cmd
   opencode.bat
   ```
4. **Magic!** OpenCode automatically adapts to the new drive letter (`F:`, `G:`, etc.). Your previous sessions, history, custom settings, and provider logins are right where you left them, **leaving zero traces or temporary files on the host computer**.

---

## 🛠️ Useful Commands & Shortcuts

* **Run a quick CLI task:**
  ```cmd
  opencode.bat run "Build a TypeScript utility to parse CSV files"
  ```
* **List available models:**
  ```cmd
  opencode.bat models
  ```
* **Update to the latest official OpenCode v2 release:**
  Double-click `update.bat` or run:
  ```cmd
  opencode.bat update
  ```
  *(The updater safely replaces the binary while preserving 100% of your data and credentials in `data/`)*.
* **Portable Developer Shell:**
  Double-click `shell.bat` to launch an isolated CMD terminal where `opencode`, `git`, and `node` are ready in the PATH without modifying host environment settings.

---

## ⚙️ Configuration

Customize your global preferences in:
```text
data/config/opencode/opencode.jsonc
```

Example:
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  // Shell environment: PowerShell 5.1+ prevents legacy CMD character rendering glitches
  "shell": "powershell.exe",

  // Active default model
  "model": "opencode/big-pickle",

  // Update check behavior: "notify" (default), true (auto), or false (disable)
  "autoupdate": "notify"
}
```

---

## 🔒 Security & Privacy

* **Drive Encryption (Highly Recommended):** OpenCode stores local authentication tokens (`service.json`), conversation history (`opencode.db`), and prompt logs in `data/`. If you carry your portable USB drive in public, we strongly recommend encrypting the drive using **BitLocker To Go** (built into Windows 10/11 Pro & Enterprise) or **VeraCrypt** (free, cross-platform open-source) to prevent unauthorized access if the physical flash drive is lost or stolen.
* **Keep your USB drive secure:** The `.gitignore` file is strictly configured to ensure personal credentials, caches, and logs are never committed to public repositories.
* For more information, see [SECURITY.md](SECURITY.md).


---

## 🤝 Contributing

Contributions, bug reports, and enhancements are welcome! Please check [CONTRIBUTING.md](CONTRIBUTING.md) before submitting pull requests.

## 📄 License

This portable wrapper project is released under the [MIT License](LICENSE). OpenCode, MinGit, and Node.js are subject to their respective upstream licenses.
