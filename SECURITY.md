# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 2.x     | :white_check_mark: |
| 1.x     | :x:                |

## Portable Data Security & Best Practices

1. **Protect Your USB Drive & Enable Drive Encryption**:
   - OpenCode stores your provider credentials (API keys configured via `/connect`), local server tokens (`service.json`), conversation databases (`opencode.db`), and prompt logs inside `data/` on your portable device.
   - **Recommended:** If carrying your USB drive across machines, encrypt the volume using **BitLocker To Go** (built into Windows 10/11 Pro/Enterprise) or **VeraCrypt** (cross-platform open source). This protects your sensitive sessions and keys in case the physical flash drive is lost or stolen.
   - Never commit or upload the contents of your `data/` folder (such as `data/profile`, `data/appdata`, or `data/config/opencode/opencode.jsonc`) to public repositories.
   - The included `.gitignore` is specifically crafted to prevent accidental tracking of your sensitive credentials.

2. **Official Upstream Sources**:
   - This project strictly downloads binaries directly from official endpoints:
     - OpenCode: [anomalyco/opencode](https://github.com/anomalyco/opencode) and [opencode.ai](https://opencode.ai)
     - Git: [git-for-windows](https://github.com/git-for-windows/git)
     - Node.js: [nodejs.org](https://nodejs.org)
   - No modified binaries or third-party proxy mirrors are used.


## Reporting a Vulnerability

If you discover a security issue or vulnerability related to the portable wrapper or script isolation, please do not open a public issue. Instead, report it via GitHub Private Vulnerability Reporting or contact the maintainers directly.
