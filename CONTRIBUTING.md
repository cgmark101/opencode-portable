# Contributing to OpenCode Portable

Thank you for your interest in contributing to **OpenCode Portable**! We welcome contributions, bug fixes, script improvements, and documentation enhancements.

## Development Guidelines

1. **Maintain Zero-Host-Dependency**:
   - Every launcher or script must assume that the host machine has zero development tools pre-installed.
   - Do not assume `git`, `node`, `curl`, or `tar` exist in the host `PATH` outside the bundled tools and standard Windows `System32`.

2. **Strict USB Isolation**:
   - All writes, configs, temporary files, logs, and caches must strictly remain isolated within `%PORTABLE_ROOT%data\`.
   - Never write to `%USERPROFILE%` or `%APPDATA%` on the host machine.

3. **Batch Script Compatibility**:
   - For `.bat` files, maintain ASCII compatibility and use `REM` or carefully placed `::` to prevent command line parsing issues across diverse Windows locale settings.

## Pull Request Process

1. Fork the repository and create your feature branch from `main`:
   ```bash
   git checkout -b feature/my-new-feature
   ```
2. Test your changes locally:
   - Run `opencode.bat` and `opencode.ps1`.
   - Verify that `update.bat` and `scripts/update.ps1` function properly.
3. Commit your changes with clear, descriptive commit messages.
4. Push to your branch and submit a Pull Request.
