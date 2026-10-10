# AGENTS.md

Instructions for AI agents working on this project.

## About the project

**opencode-portable** is a fully self-contained, zero-host-dependency portable distribution of **OpenCode v2** designed specifically for **Windows 10 and 11**. It is built to run entirely from USB flash drives or external drives without altering or relying on the host operating system.

Core project documentation is maintained in [README.md](./README.md) (English) and [README.es.md](./README.es.md) (Spanish).

## Technology stack

- **Scripting & Launchers:** Windows Command Script (`.bat`) and PowerShell 5.1+ (`.ps1`)
- **Core Binary:** Official compiled native 64-bit OpenCode v2 executable (`bin/opencode.exe`)
- **Embedded Toolchain:**
  - Official MinGit with Busybox (`tools/git/`) for version control, diffs, and Unix shell tools
  - Official Node.js Portable LTS (`tools/node/`) for Model Context Protocol (MCP) servers and npm tools
- **Configuration Format:** JSONC (`opencode.jsonc`) validated against `https://opencode.ai/config.json`
- **CI / Automation:** GitHub Actions (`windows-latest`) running syntax AST validation and automated test suites

---

## Architecture & Isolation Rules

### The Golden Rule of Portability

**Everything persistent MUST live inside `%PORTABLE_ROOT%\data\`. Never touch the host filesystem.**

1. **Environment Redirection:**
   - OpenCode paths: `OPENCODE_CONFIG_DIR`, `OPENCODE_DATA_DIR`, `OPENCODE_CACHE_DIR`, `OPENCODE_STATE_DIR`, `OPENCODE_LOG_DIR`
   - XDG Base Directories: `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME`, `XDG_STATE_HOME`
   - Host isolation: `USERPROFILE`, `HOME`, `APPDATA`, `LOCALAPPDATA`, `TEMP`, `TMP`
2. **Path Isolation:**
   - Launchers prioritize `%PORTABLE_ROOT%\bin` and `%PORTABLE_ROOT%\tools\...` before Windows system folders.
   - User paths from the host machine are explicitly excluded from `PATH`.
3. **No Third-Party Mirror Dependencies:**
   - All downloaders (`scripts/setup.ps1`, `scripts/update.ps1`) must fetch directly from official endpoints (`opencode.ai`, `github.com/anomalyco/opencode`, `nodejs.org`, `github.com/git-for-windows/git`).

---

## AI Agent Behavior Rules

### Communication

- **Response Language:** Reply in the same language the user uses in their prompt.
- **Clarifications:** If requirements are ambiguous, ask before proceeding. Do not make unconfirmed architectural changes or mass file modifications silently.

### Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them rather than picking silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something in Windows batch parsing or PowerShell is ambiguous, test first in a subshell.

### Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use scripts.
- No "flexibility" or "configurability" that wasn't requested.
- Keep `.bat` scripts simple, maintainable, and strictly compatible with standard `cmd.exe`.
- If 20 lines of clean PowerShell solve the problem, do not write a complex module.

### Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent scripts, comments, or formatting unnecessarily.
- Don't refactor things that aren't broken.
- Match existing style: ASCII comments in `.bat`, standard parameter blocks in `.ps1`.
- Clean up temporary files created during script execution in `data\temp\`.

---

## 🎯 Testing & Quality Assurance (STRICT RULES)

**Every change must be verifiable. Loop until the test suite passes.**

### Mandatory Testing Policy

1. **Never declare a task done without running the test suite:**
   - Any modification to `scripts/env.bat`, `opencode.bat`, `opencode.ps1`, `scripts/update.ps1`, or directory layouts must be verified by running:
     ```powershell
     powershell -NoProfile -ExecutionPolicy Bypass -File scripts\test.ps1
     ```
   - **All tests must pass (100% success rate).**
2. **Continuous Integration Guardrails:**
   - GitHub Actions runs `.github/workflows/ci.yml` on every Push and Pull Request.
   - CI executes `scripts/test.ps1` on a live Windows runner. If even one test fails, CI fails and blocks the PR.
3. **Extend Tests for New Features:**
   - If you add a new environment variable, tool directory, or launcher feature, you **MUST add a corresponding assertion** to `scripts/test.ps1`.
4. **Transform Bug Reports into Verifiable Goals:**
   - "Fix path separator bug" → "Add test assertion reproducing the separator failure → fix the script → ensure `test.ps1` passes."

### Structure of `scripts/test.ps1`

- **Test 1:** Environment Isolation (`OPENCODE_CONFIG_DIR`, `USERPROFILE`, `APPDATA` pointing to USB data root)
- **Test 2:** Native OpenCode v2 binary resolution (`bin\opencode.exe`)
- **Test 3:** Embedded Git Portable execution & resolution
- **Test 4:** Embedded Node.js Portable execution & resolution
- **Test 5:** Primary Batch Launcher execution (`opencode.bat --version`)
- **Test 6:** Primary PowerShell Launcher execution (`opencode.ps1 --version`)
- **Test 7:** Portable Skills directory structure and detection (`data\config\opencode\skills`)
- **Test 8:** Official Upstream Update check (`scripts/update.ps1 -CheckOnly`)
- **Test 9:** PowerShell AST Syntax validation for all `.ps1` scripts
- **Test 10:** Default configuration model and PowerShell shell specification (`opencode.jsonc`)
- **Test 11:** Primary batch launcher in-place execution (`opencode.bat --no-wt --version`)
- **Test 12:** PowerShell launcher update forwarding (`opencode.ps1 update -CheckOnly`)
- **Test 13:** Launcher argument sanitization & lossless forwarding (`--no-wt` stripping without delayed expansion corruption)
- **Test 14:** Configuration schema compliance (`autoupdate` key validation)
- **Test 15:** Batch launcher update forwarding (`opencode.bat update --check-only`)



---

## Working with Windows Batch & PowerShell

- **Batch Parsing Gotchas:**
  - Do not use non-ASCII characters or accented letters in `.bat` comments (`::` or `REM`) to avoid locale-dependent parsing issues in `cmd.exe`.
  - Always use `cmd /v:on` when inspecting delayed environment variables in tests.
  - Normalize path variables to avoid double backslashes (e.g., use `%PORTABLE_ROOT%\data` where `%PORTABLE_ROOT%` has no trailing slash).
- **PowerShell Scripting:**
  - Keep scripts compatible with Windows PowerShell 5.1 (the default on Windows 10) as well as PowerShell 7+.
  - Avoid fragile one-liners with unchecked pipeline variables.
  - Use proper ErrorAction and try/catch blocks around external network downloads (`curl.exe`) and archiving commands.

---

## Git Workflow

- **Commits:** Never create commits automatically without explicit instruction from the user.
- **Repository Hygiene:**
  - Never track binaries (`*.exe`, `tools/git/`, `tools/node/`) or archives (`*.zip`, `*.tgz`).
  - Never commit user credentials or state (`data/profile/`, `data/config/opencode/opencode.jsonc`, `data/share/`).
  - Keep placeholders with `.gitkeep` files to preserve directory structure on clean clones.
- **Amending / Squash:** When requested by the user, squash or amend commits cleanly to maintain a minimal, production-ready git history.
