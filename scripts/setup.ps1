<#
.SYNOPSIS
    Initial setup and bootstrap script for OpenCode Portable v2.
.DESCRIPTION
    Downloads official OpenCode v2, Git Portable (MinGit), and Node.js Portable LTS,
    leaving the USB drive 100% self-contained and ready to run on any Windows 10/11
    without requiring dependencies on the host machine.
#>

[CmdletBinding()]
param(
    [switch]$SkipGit,
    [switch]$SkipNode,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$ScriptsDir = $PSScriptRoot
$PortableRoot = (Resolve-Path "$ScriptsDir\..").Path
$BinDir = Join-Path $PortableRoot "bin"
$ToolsDir = Join-Path $PortableRoot "tools"
$GitDir = Join-Path $ToolsDir "git"
$NodeDir = Join-Path $ToolsDir "node"
$DataDir = Join-Path $PortableRoot "data"
$ConfigDir = Join-Path $DataDir "config\opencode"
$TempDir = Join-Path $DataDir "temp"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     OpenCode Portable - Full Automated Bootstrap         " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Target: $PortableRoot`n" -ForegroundColor DarkGray

# 1. Create isolated directory structure
Write-Host "[1/4] Creating isolated directory layout..." -ForegroundColor Yellow
$Directories = @(
    $BinDir,
    $ToolsDir,
    $GitDir,
    $NodeDir,
    $ConfigDir,
    (Join-Path $DataDir "share\opencode"),
    (Join-Path $DataDir "cache\opencode"),
    (Join-Path $DataDir "state\opencode"),
    (Join-Path $DataDir "logs"),
    (Join-Path $DataDir "profile"),
    (Join-Path $DataDir "appdata\roaming"),
    (Join-Path $DataDir "appdata\local"),
    $TempDir
)

foreach ($dir in $Directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# 2. Download OpenCode v2 using the official update script
Write-Host "`n[2/4] Fetching latest official OpenCode v2 binary..." -ForegroundColor Yellow
& (Join-Path $ScriptsDir "update.ps1") -Force:$Force

# 3. Bootstrap Git Portable (MinGit with busybox) if missing
if (-not $SkipGit) {
    $GitExe = Join-Path $GitDir "cmd\git.exe"
    if ((Test-Path $GitExe) -and (-not $Force)) {
        Write-Host "`n[3/4] Git Portable is already installed in $GitDir." -ForegroundColor Green
    } else {
        Write-Host "`n[3/4] Downloading official Git Portable (MinGit)..." -ForegroundColor Yellow
        try {
            $Rel = Invoke-RestMethod -Uri "https://api.github.com/repos/git-for-windows/git/releases/latest" -TimeoutSec 15
            $Asset = $Rel.assets | Where-Object { $_.name -match 'MinGit-.*-busybox-64-bit\.zip$' } | Select-Object -First 1
            if (-not $Asset) {
                $Asset = $Rel.assets | Where-Object { $_.name -match 'MinGit-.*-64-bit\.zip$' } | Select-Object -First 1
            }
            if ($Asset) {
                $GitZip = Join-Path $TempDir "mingit.zip"
                Write-Host "Downloading $($Asset.name)..." -ForegroundColor Gray
                $curlProc = Start-Process -FilePath "curl.exe" -ArgumentList "-L", "--fail", "--retry", "3", "$($Asset.browser_download_url)", "-o", "`"$GitZip`"" -NoNewWindow -Wait -PassThru
                if ($curlProc.ExitCode -eq 0 -and (Test-Path $GitZip) -and ((Get-Item $GitZip).Length -gt 100000)) {
                    Write-Host "Extracting Git Portable..." -ForegroundColor Gray
                    Expand-Archive -Path $GitZip -DestinationPath $GitDir -Force
                    Remove-Item $GitZip -Force -ErrorAction SilentlyContinue
                    Write-Host "[OK] Git Portable successfully installed." -ForegroundColor Green
                } else {
                    Remove-Item $GitZip -Force -ErrorAction SilentlyContinue
                    throw "MinGit download failed or corrupted (curl exit code: $($curlProc.ExitCode))."
                }
            }
        } catch {
            Write-Warning "Could not download MinGit automatically: $($_.Exception.Message)"
        }
    }
} else {
    Write-Host "`n[3/4] Skipping Git Portable installation (-SkipGit)." -ForegroundColor Gray
}

# 4. Bootstrap Node.js Portable LTS if missing
if (-not $SkipNode) {
    $NodeExe = Join-Path $NodeDir "node.exe"
    if ((Test-Path $NodeExe) -and (-not $Force)) {
        Write-Host "`n[4/4] Node.js Portable is already installed in $NodeDir." -ForegroundColor Green
    } else {
        Write-Host "`n[4/4] Downloading official Node.js Portable LTS..." -ForegroundColor Yellow
        try {
            $NodeList = Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json" -TimeoutSec 15
            $NodeLts = $NodeList | Where-Object { $_.lts } | Select-Object -First 1
            if ($NodeLts) {
                $Ver = $NodeLts.version
                $NodeZipUrl = "https://nodejs.org/dist/$Ver/node-$Ver-win-x64.zip"
                $NodeZipPath = Join-Path $TempDir "node.zip"
                Write-Host "Downloading Node.js $Ver..." -ForegroundColor Gray
                $curlProc = Start-Process -FilePath "curl.exe" -ArgumentList "-L", "--fail", "--retry", "3", "$NodeZipUrl", "-o", "`"$NodeZipPath`"" -NoNewWindow -Wait -PassThru
                if ($curlProc.ExitCode -eq 0 -and (Test-Path $NodeZipPath) -and ((Get-Item $NodeZipPath).Length -gt 100000)) {
                    Write-Host "Extracting Node.js Portable..." -ForegroundColor Gray
                    $ExtractTemp = Join-Path $TempDir "node_extracted"
                    Expand-Archive -Path $NodeZipPath -DestinationPath $ExtractTemp -Force
                    $InnerDir = Join-Path $ExtractTemp "node-$Ver-win-x64"
                    if (Test-Path $InnerDir) {
                        Get-ChildItem -Path $InnerDir | Move-Item -Destination $NodeDir -Force
                    }
                    Remove-Item -Path $ExtractTemp -Recurse -Force -ErrorAction SilentlyContinue
                    Remove-Item $NodeZipPath -Force -ErrorAction SilentlyContinue
                    Write-Host "[OK] Node.js Portable successfully installed." -ForegroundColor Green
                } else {
                    Remove-Item $NodeZipPath -Force -ErrorAction SilentlyContinue
                    throw "Node.js download failed or corrupted (curl exit code: $($curlProc.ExitCode))."
                }
            }
        } catch {
            Write-Warning "Could not download Node.js automatically: $($_.Exception.Message)"
        }
    }
} else {
    Write-Host "`n[4/4] Skipping Node.js installation (-SkipNode)." -ForegroundColor Gray
}

# 5. Create default configuration file if missing
$ConfigFile = Join-Path $ConfigDir "opencode.jsonc"
$ExampleConfig = Join-Path $ConfigDir "opencode.example.jsonc"
if (-not (Test-Path $ConfigFile)) {
    Write-Host "`nCreating default configuration at: data\config\opencode\opencode.jsonc" -ForegroundColor Cyan
    if (Test-Path $ExampleConfig) {
        Copy-Item -Path $ExampleConfig -Destination $ConfigFile -Force
    } else {
        $DefaultConfig = @'
{
  "$schema": "https://opencode.ai/config.json",
  "shell": "powershell.exe",
  "model": "opencode/big-pickle",
  "small_model": "opencode/nemotron-3.5-lightning-free",
  "autoupdate": "notify"
}
'@
        Set-Content -Path $ConfigFile -Value $DefaultConfig -Encoding utf8
    }
}


Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "   Portable Suite Ready to Use on Any PC!                 " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "To launch OpenCode, double-click:" -ForegroundColor White
Write-Host "  -> opencode.bat`n" -ForegroundColor Yellow
