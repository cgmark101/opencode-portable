<#
.SYNOPSIS
    OpenCode v2 portable launcher for PowerShell on Windows 10 & 11.
.DESCRIPTION
    Fully isolates session state, configs, profiles, and dependencies to the portable root.
#>

[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$OpenCodeArgs
)

$PortableRoot = Split-Path -Parent $PSScriptRoot
if (-not $PortableRoot) { $PortableRoot = $PSScriptRoot }
if (Test-Path (Join-Path $PSScriptRoot "scripts\env.bat")) {
    $PortableRoot = $PSScriptRoot
}

# Directories for data and tools
$BinDir       = Join-Path $PortableRoot "bin"
$ToolsDir     = Join-Path $PortableRoot "tools"
$ConfigDir    = Join-Path $PortableRoot "data\config\opencode"
$SkillsDir    = Join-Path $ConfigDir "skills"
$ShareDir     = Join-Path $PortableRoot "data\share\opencode"
$CacheDir     = Join-Path $PortableRoot "data\cache\opencode"
$StateDir     = Join-Path $PortableRoot "data\state\opencode"
$LogsDir      = Join-Path $PortableRoot "data\logs"
$ProfileDir   = Join-Path $PortableRoot "data\profile"
$RoamingDir   = Join-Path $PortableRoot "data\appdata\roaming"
$LocalDir     = Join-Path $PortableRoot "data\appdata\local"
$TempDir      = Join-Path $PortableRoot "data\temp"

# Ensure directories exist
@($BinDir, $ToolsDir, $ConfigDir, $SkillsDir, $ShareDir, $CacheDir, $StateDir, $LogsDir, $ProfileDir, $RoamingDir, $LocalDir, $TempDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

# OpenCode v2 official environment variables
$env:OPENCODE_CONFIG_DIR = $ConfigDir
$env:OPENCODE_DATA_DIR   = $ShareDir
$env:OPENCODE_CACHE_DIR  = $CacheDir
$env:OPENCODE_STATE_DIR  = $StateDir
$env:OPENCODE_LOG_DIR    = $LogsDir

# XDG Base Directory specification
$env:XDG_CONFIG_HOME     = Join-Path $PortableRoot "data\config"
$env:XDG_DATA_HOME       = Join-Path $PortableRoot "data\share"
$env:XDG_CACHE_HOME      = Join-Path $PortableRoot "data\cache"
$env:XDG_STATE_HOME      = Join-Path $PortableRoot "data\state"

# Isolated Windows profile and AppData
$env:USERPROFILE         = $ProfileDir
$env:HOME                = $ProfileDir
$env:APPDATA             = $RoamingDir
$env:LOCALAPPDATA        = $LocalDir
$env:TEMP                = $TempDir
$env:TMP                 = $TempDir
$env:GIT_CONFIG_GLOBAL   = Join-Path $PortableRoot "data\config\.gitconfig"

# Redirect PowerShell module analysis cache
$PSCacheDir = Join-Path $PortableRoot "data\cache\powershell"
if (-not (Test-Path $PSCacheDir)) { New-Item -ItemType Directory -Path $PSCacheDir -Force | Out-Null }
$env:PSModuleAnalysisCachePath = Join-Path $PSCacheDir "ModuleAnalysisCache"


# Configure prioritized PATH
$PathEntries = [System.Collections.Generic.List[string]]::new()
$PathEntries.Add($BinDir)

$GitCmd = Join-Path $ToolsDir "git\cmd"
$GitUsr = Join-Path $ToolsDir "git\usr\bin"
$GitBin = Join-Path $ToolsDir "git\bin"
$NodeDir = Join-Path $ToolsDir "node"

if (Test-Path $GitCmd) { $PathEntries.Add($GitCmd) }
if (Test-Path $GitUsr) { $PathEntries.Add($GitUsr) }
if (Test-Path $GitBin) { $PathEntries.Add($GitBin) }
if (Test-Path $NodeDir) { $PathEntries.Add($NodeDir) }

# Essential Windows system paths
$WinSys = @(
    "$env:SystemRoot\system32",
    "$env:SystemRoot",
    "$env:SystemRoot\System32\Wbem",
    "$env:SystemRoot\System32\WindowsPowerShell\v1.0\"
)
foreach ($ws in $WinSys) { $PathEntries.Add($ws) }
$env:PATH = ($PathEntries -join ";")

# Filter internal flags like --no-wt so they are never passed downstream to opencode.exe
$FilteredArgs = @($OpenCodeArgs | Where-Object { $_ -ne "--no-wt" })

# Handle update subcommand
if ($FilteredArgs.Count -gt 0 -and ($FilteredArgs[0] -eq "update" -or $FilteredArgs[0] -eq "--update")) {
    $isCheckOnly = ($FilteredArgs -contains "-CheckOnly") -or ($FilteredArgs -contains "--check-only")
    $isForce = ($FilteredArgs -contains "-Force") -or ($FilteredArgs -contains "--force")
    & (Join-Path $PortableRoot "scripts\update.ps1") -CheckOnly:$isCheckOnly -Force:$isForce
    exit $LASTEXITCODE
}


$ExePath = Join-Path $BinDir "opencode.exe"
if (-not (Test-Path $ExePath)) {
    Write-Host "`n[OpenCode Portable] Binary not found at $ExePath" -ForegroundColor Yellow
    Write-Host "Running automatic setup for OpenCode v2...`n" -ForegroundColor Cyan
    & (Join-Path $PortableRoot "scripts\setup.ps1")
    if (-not (Test-Path $ExePath)) {
        Write-Error "[ERROR] Could not find or download OpenCode v2."
        exit 1
    }
}

# Ensure complete UTF-8 encoding support to avoid TUI/character corruption
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    $OutputEncoding           = [System.Text.Encoding]::UTF8
} catch {
    # Non-fatal if host environment restricts console stream modifications
}

# Launch OpenCode
& $ExePath @FilteredArgs
exit $LASTEXITCODE


