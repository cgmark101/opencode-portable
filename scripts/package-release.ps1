<#
.SYNOPSIS
    Packages a clean portable distribution into a ZIP archive for GitHub Releases.
#>

[CmdletBinding()]
param(
    [string]$OutFile = "opencode-portable-windows-x64.zip"
)

$ErrorActionPreference = "Stop"

$ScriptsDir = $PSScriptRoot
$PortableRoot = (Resolve-Path "$ScriptsDir\..").Path
$TempDist = Join-Path $PortableRoot "dist_temp"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     OpenCode Portable - Building Release Package         " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

if (Test-Path $TempDist) {
    Remove-Item -Path $TempDist -Recurse -Force
}
New-Item -ItemType Directory -Path $TempDist -Force | Out-Null

$FilesToCopy = @(
    "opencode.bat",
    "opencode.ps1",
    "update.bat",
    "shell.bat",
    "test.bat",
    "README.md",
    "README.es.md",
    "LICENSE",
    "CONTRIBUTING.md",
    "SECURITY.md",
    ".gitignore",
    "AGENTS.md"
)

foreach ($f in $FilesToCopy) {
    $src = Join-Path $PortableRoot $f
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $TempDist -Force
    }
}


# Copy scripts directory
Copy-Item -Path (Join-Path $PortableRoot "scripts") -Destination (Join-Path $TempDist "scripts") -Recurse -Force

# Recreate clean directory structure for data, bin and tools
$CleanDirs = @(
    "bin",
    "tools",
    "data/config/opencode",
    "data/config/opencode/skills",
    "data/share",
    "data/cache",
    "data/state",
    "data/logs",
    "data/profile",
    "data/appdata/roaming",
    "data/appdata/local",
    "data/temp"
)

foreach ($d in $CleanDirs) {
    $dest = Join-Path $TempDist $d
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    Set-Content -Path (Join-Path $dest ".gitkeep") -Value "" -Encoding utf8
}

# Copy configuration template
$ExCfg = Join-Path $PortableRoot "data\config\opencode\opencode.example.jsonc"
if (Test-Path $ExCfg) {
    Copy-Item -Path $ExCfg -Destination (Join-Path $TempDist "data\config\opencode\opencode.example.jsonc") -Force
}

# Copy example skill template
$SkillSrc = Join-Path $PortableRoot "data\config\opencode\skills\git-workflow"
if (Test-Path $SkillSrc) {
    Copy-Item -Path $SkillSrc -Destination (Join-Path $TempDist "data\config\opencode\skills\git-workflow") -Recurse -Force
}

$ZipTarget = Join-Path $PortableRoot $OutFile

if (Test-Path $ZipTarget) {
    Remove-Item -Path $ZipTarget -Force
}

Write-Host "Compressing release package into $OutFile..." -ForegroundColor Gray
Compress-Archive -Path "$TempDist\*" -DestinationPath $ZipTarget -Force
Remove-Item -Path $TempDist -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n[SUCCESS] Package successfully created:" -ForegroundColor Green
Write-Host "  -> $ZipTarget`n" -ForegroundColor Yellow
