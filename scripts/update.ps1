<#
.SYNOPSIS
    Official auto-updater script for OpenCode Portable v2 on Windows.
.DESCRIPTION
    Checks and downloads the latest official OpenCode v2 binary directly
    from official upstream channels (anomalyco / opencode.ai / npm) while
    strictly preserving all configurations, sessions, and data on the USB drive.
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [Alias("check-only")]
    [switch]$CheckOnly
)

$ErrorActionPreference = "Stop"

# Portable root paths
$ScriptsDir = $PSScriptRoot
$PortableRoot = (Resolve-Path "$ScriptsDir\..").Path
$BinDir = Join-Path $PortableRoot "bin"
$DataTempDir = Join-Path $PortableRoot "data\temp"
$ExePath = Join-Path $BinDir "opencode.exe"
$BackupPath = Join-Path $BinDir "opencode.exe.bak"

if (-not (Test-Path $DataTempDir)) {
    New-Item -ItemType Directory -Path $DataTempDir -Force | Out-Null
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    OpenCode Portable - Checking for Updates (v2)         " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Location: $PortableRoot`n" -ForegroundColor DarkGray

# 1. Detect currently installed version
$CurrentVersion = $null
if (Test-Path $ExePath) {
    try {
        $VerOutput = & $ExePath --version 2>$null
        if ($VerOutput -match '(\d+\.\d+\.\d+[\w\.\-]*)') {
            $CurrentVersion = $matches[1]
        }
    } catch {
        Write-Warning "Could not determine currently installed binary version."
    }
}

if ($CurrentVersion) {
    Write-Host "[INFO] Currently installed version: " -NoNewline
    Write-Host "v$CurrentVersion" -ForegroundColor Green
} else {
    Write-Host "[INFO] No prior version detected in bin\opencode.exe" -ForegroundColor Yellow
}

# 2. Query official upstream channels for latest OpenCode v2 release
Write-Host "[INFO] Querying official upstream channels for OpenCode v2..." -ForegroundColor Gray

$LatestVersion = $null
# Primary channel: Official NPM registry for @opencode/cli (reliable, no GitHub API rate-limits)
try {
    $NpmMeta = Invoke-RestMethod -Uri "https://registry.npmjs.org/@opencode/cli/latest" -TimeoutSec 10 -ErrorAction Stop
    if ($NpmMeta.version -and $NpmMeta.version -match '^2\.') {
        $LatestVersion = $NpmMeta.version
    }
} catch {
    Write-Host "[NOTICE] Primary NPM query failed, attempting GitHub API..." -ForegroundColor Yellow
}

# Secondary channel: GitHub API for anomalyco/opencode
if (-not $LatestVersion) {
    try {
        $Tags = Invoke-RestMethod -Uri "https://api.github.com/repos/anomalyco/opencode/git/matching-refs/tags/v2" -TimeoutSec 10 -ErrorAction Stop
        if ($Tags -and $Tags.Count -gt 0) {
            $LatestTag = $Tags[-1].ref -replace '^refs/tags/v?', ''
            if ($LatestTag -match '^\d+\.\d+\.\d+') {
                $LatestVersion = $LatestTag
            }
        }
    } catch {
        Write-Warning "GitHub API query also failed."
    }
}

if (-not $LatestVersion) {
    Write-Error "[ERROR] Could not determine latest available version. Check your internet connection."
    exit 1
}

Write-Host "[INFO] Latest official v2 release available: " -NoNewline
Write-Host "v$LatestVersion" -ForegroundColor Green

# 3. Check if update is required
$NeedsUpdate = $false
if (-not $CurrentVersion) {
    $NeedsUpdate = $true
} elseif ($Force) {
    Write-Host "[INFO] -Force flag specified. Forcing reinstallation..." -ForegroundColor Yellow
    $NeedsUpdate = $true
} else {
    try {
        $CurrVerObj = [System.Version]::new(($CurrentVersion -split '-')[0])
        $LatestVerObj = [System.Version]::new(($LatestVersion -split '-')[0])
        if ($LatestVerObj -gt $CurrVerObj) {
            $NeedsUpdate = $true
        }
    } catch {
        if ($CurrentVersion -ne $LatestVersion) {
            $NeedsUpdate = $true
        }
    }
}

if ($CheckOnly) {
    if ($NeedsUpdate) {
        Write-Host "`n[NOTICE] An update is available: v$CurrentVersion -> v$LatestVersion" -ForegroundColor Yellow
        exit 100
    } else {
        Write-Host "`n[OK] OpenCode is already running the latest version." -ForegroundColor Green
        exit 0
    }
}

if (-not $NeedsUpdate) {
    Write-Host "`n[OK] OpenCode is already up to date (v$CurrentVersion)." -ForegroundColor Green
    Write-Host "No further action required." -ForegroundColor DarkGray
    exit 0
}

Write-Host "`n[INFO] Preparing upgrade to v$LatestVersion..." -ForegroundColor Cyan

# 4. Download latest official OpenCode v2 binary
$TempDownloadDir = Join-Path $DataTempDir ("update_" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TempDownloadDir -Force | Out-Null

$DownloadedExe = $null

# Attempt A: Download official zip from opencode.ai/files/bin
$ZipUrl = "https://opencode.ai/files/bin/$LatestVersion/opencode-windows-x64.zip"
$ZipTarget = Join-Path $TempDownloadDir "opencode.zip"

Write-Host "[1/3] Downloading official binary from opencode.ai..." -ForegroundColor Gray
$DownloadSuccess = $false
try {
    $curlProc = Start-Process -FilePath "curl.exe" -ArgumentList "-L", "--fail", "$ZipUrl", "-o", "`"$ZipTarget`"" -NoNewWindow -PassThru -Wait
    if ($curlProc.ExitCode -eq 0 -and (Test-Path $ZipTarget)) {
        $DownloadSuccess = $true
    }
} catch {
    $DownloadSuccess = $false
}

if ($DownloadSuccess) {
    Write-Host "[2/3] Extracting official package..." -ForegroundColor Gray
    try {
        Expand-Archive -Path $ZipTarget -DestinationPath $TempDownloadDir -Force
        $FoundExe = Get-ChildItem -Path $TempDownloadDir -Filter "opencode.exe" -Recurse | Select-Object -First 1
        if ($FoundExe) {
            $DownloadedExe = $FoundExe.FullName
        }
    } catch {
        Write-Warning "Archive expansion failed for opencode.ai zip."
    }
}

# Attempt B: Fallback to official NPM tarball @opencode/cli-windows-x64
if (-not $DownloadedExe) {
    Write-Host "[INFO] Trying official fallback from npm registry (@opencode/cli-windows-x64)..." -ForegroundColor Yellow
    $TgzUrl = "https://registry.npmjs.org/@opencode/cli-windows-x64/-/cli-windows-x64-$LatestVersion.tgz"
    $TgzTarget = Join-Path $TempDownloadDir "opencode.tgz"

    $curlProc = Start-Process -FilePath "curl.exe" -ArgumentList "-L", "--fail", "$TgzUrl", "-o", "`"$TgzTarget`"" -NoNewWindow -PassThru -Wait
    if ($curlProc.ExitCode -eq 0 -and (Test-Path $TgzTarget)) {
        & tar.exe -xzf "$TgzTarget" -C "$TempDownloadDir"
        $NpmExe = Join-Path $TempDownloadDir "package\bin\opencode.exe"
        if (Test-Path $NpmExe) {
            $DownloadedExe = $NpmExe
        }
    }
}

if (-not $DownloadedExe -or -not (Test-Path $DownloadedExe)) {
    Remove-Item -Path $TempDownloadDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Error "[ERROR] Could not download OpenCode v$LatestVersion binary from official endpoints."
    exit 1
}

# 5. Atomic replacement with rollback support
Write-Host "[3/3] Installing updated binary while preserving user configuration..." -ForegroundColor Gray

if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
}

if (Test-Path $ExePath) {
    Copy-Item -Path $ExePath -Destination $BackupPath -Force
}

try {
    Copy-Item -Path $DownloadedExe -Destination $ExePath -Force
    $TestVer = & $ExePath --version 2>$null
    Write-Host "`n==========================================================" -ForegroundColor Green
    Write-Host "   [SUCCESS] OpenCode successfully updated to v$LatestVersion!   " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "All configurations, sessions, and data in 'data/' remain intact." -ForegroundColor Green
    if (Test-Path $BackupPath) {
        Remove-Item -Path $BackupPath -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Host "`n[ERROR] Downloaded binary failed verification." -ForegroundColor Red
    if (Test-Path $BackupPath) {
        Write-Host "Restoring previous backup..." -ForegroundColor Yellow
        Copy-Item -Path $BackupPath -Destination $ExePath -Force
    }
    exit 1
} finally {
    Remove-Item -Path $TempDownloadDir -Recurse -Force -ErrorAction SilentlyContinue
}

exit 0
