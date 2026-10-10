<#
.SYNOPSIS
    Automated test suite for OpenCode Portable v2 (Windows 10/11).
.DESCRIPTION
    Validates environment isolation, self-contained runtimes, OpenCode execution,
    skills discovery, and auto-updater.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"

$ScriptsDir = $PSScriptRoot
$PortableRoot = (Resolve-Path "$ScriptsDir\..").Path

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    OpenCode Portable v2 - Automated Test Suite           " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Evaluated directory: $PortableRoot`n" -ForegroundColor DarkGray

$TotalTests = 0
$PassedTests = 0

function Assert-Test([string]$TestName, [scriptblock]$Condition) {
    $script:TotalTests++
    Write-Host -NoNewline "[TEST $script:TotalTests] $TestName ... "
    try {
        $result = & $Condition
        if ($result -eq $true) {
            $script:PassedTests++
            Write-Host "PASSED" -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAILED" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "ERROR ($($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

# 1. Environment isolation test
Assert-Test "Environment isolation via env.bat" {
    $envTest = cmd /v:on /c "call `"$PortableRoot\scripts\env.bat`" && echo CFG=!OPENCODE_CONFIG_DIR!&& echo PROF=!USERPROFILE!&& echo APP=!APPDATA!"
    $cfgExpected = "$PortableRoot\data\config\opencode"
    $profExpected = "$PortableRoot\data\profile"
    $appExpected = "$PortableRoot\data\appdata\roaming"
    return (($envTest -join " ") -match [regex]::Escape($cfgExpected) -and ($envTest -join " ") -match [regex]::Escape($profExpected))
}

# 2. OpenCode binary resolution test
Assert-Test "Official bin/opencode.exe binary resolution" {
    $exePath = Join-Path $PortableRoot "bin\opencode.exe"
    if (-not (Test-Path $exePath)) { return $false }
    $ver = & $exePath --version 2>$null
    return ($ver -match "opencode v2")
}

# 3. Embedded Git Portable test
Assert-Test "Embedded Git Portable resolution and execution" {
    $gitRes = cmd /v:on /c "call `"$PortableRoot\scripts\env.bat`" && where git"
    $gitVer = cmd /v:on /c "call `"$PortableRoot\scripts\env.bat`" && git --version"
    $isIsolated = ($gitRes -join " ") -match [regex]::Escape("$PortableRoot\tools\git")
    return ($isIsolated -and (($gitVer -join " ") -match "git version"))
}

# 4. Embedded Node.js Portable test
Assert-Test "Embedded Node.js Portable resolution and execution" {
    $nodeRes = cmd /v:on /c "call `"$PortableRoot\scripts\env.bat`" && where node"
    $nodeVer = cmd /v:on /c "call `"$PortableRoot\scripts\env.bat`" && node --version"
    $isIsolated = ($nodeRes -join " ") -match [regex]::Escape("$PortableRoot\tools\node")
    return ($isIsolated -and (($nodeVer -join " ") -match "v24"))
}

# 5. Primary batch launcher test
Assert-Test "Primary batch launcher execution (opencode.bat)" {
    $batOutput = cmd /c "`"$PortableRoot\opencode.bat`" --version"
    return ($batOutput -match "opencode v2")
}

# 6. PowerShell launcher test
Assert-Test "Native PowerShell launcher execution (opencode.ps1)" {
    $psOutput = powershell -NoProfile -ExecutionPolicy Bypass -File "$PortableRoot\opencode.ps1" --version
    return ($psOutput -match "opencode v2")
}

# 7. Portable Skills discovery test
Assert-Test "Portable Skills directory and example detection" {
    $skillsDir = Join-Path $PortableRoot "data\config\opencode\skills"
    $exampleSkill = Join-Path $skillsDir "git-workflow\SKILL.md"
    if (-not (Test-Path $exampleSkill)) { return $false }
    $content = Get-Content $exampleSkill -Raw
    return ($content -match "name: Git Workflow" -and $content -match "description:")
}

# 8. Auto-updater check-only test
Assert-Test "Official upstream check with update.ps1 -CheckOnly" {
    $upOutput = powershell -NoProfile -ExecutionPolicy Bypass -File "$PortableRoot\scripts\update.ps1" -CheckOnly
    return ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 100)
}

# 9. PowerShell AST syntax validation
Assert-Test "PowerShell AST syntax validation for all .ps1 scripts" {
    $scripts = Get-ChildItem -Path $PortableRoot -Filter *.ps1 -Recurse
    foreach ($s in $scripts) {
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($s.FullName, [ref]$null, [ref]$errors) | Out-Null
        if ($errors.Count -gt 0) { return $false }
    }
    return $true
}

# 10. Default model and PowerShell shell specification test
Assert-Test "Default config model and PowerShell shell specification" {
    $cfgPath = Join-Path $PortableRoot "data\config\opencode\opencode.example.jsonc"
    if (-not (Test-Path $cfgPath)) {
        $cfgPath = Join-Path $PortableRoot "data\config\opencode\opencode.jsonc"
    }
    if (-not (Test-Path $cfgPath)) { return $false }
    $cfgText = Get-Content $cfgPath -Raw
    return ($cfgText -match '"shell":\s*"powershell\.exe"' -and $cfgText -match '"model":\s*"opencode/big-pickle"')
}


# 11. In-place batch launcher test with --no-wt flag
Assert-Test "Primary batch launcher in-place execution (opencode.bat --no-wt)" {
    $batOutput = cmd /c "`"$PortableRoot\opencode.bat`" --no-wt --version"
    return ($batOutput -match "opencode v2")
}

# 12. PowerShell launcher update forwarding test (opencode.ps1 update -CheckOnly)
Assert-Test "PowerShell launcher update forwarding (opencode.ps1 update -CheckOnly)" {
    $upOutput = powershell -NoProfile -ExecutionPolicy Bypass -File "$PortableRoot\opencode.ps1" update -CheckOnly
    return ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 100)
}

# 13. Launcher argument sanitization & lossless forwarding test
Assert-Test "Launcher flag stripping and lossless argument preservation" {
    $batContent = Get-Content (Join-Path $PortableRoot "opencode.bat") -Raw
    $noDelayedExp = ($batContent -notmatch "enabledelayedexpansion")
    $noForLoopGlob = ($batContent -notmatch 'for\s+%%[a-zA-Z]\s+in\s+\(%\*\)')
    $passesRawArgs = ($batContent -match 'opencode\.ps1"\s+%\*')
    $batOut = cmd /c "`"$PortableRoot\opencode.bat`" --no-wt --version"
    return ($noDelayedExp -and $noForLoopGlob -and $passesRawArgs -and ($batOut -match "opencode v2") -and ($batOut -notmatch "Unrecognized flag: --no-wt"))
}

# 14. Configuration schema key validation (autoupdate instead of deprecated update)
Assert-Test "Configuration schema compliance (autoupdate key in templates and fallback)" {
    $exCfg = Get-Content (Join-Path $PortableRoot "data\config\opencode\opencode.example.jsonc") -Raw
    $setupPs1 = Get-Content (Join-Path $PortableRoot "scripts\setup.ps1") -Raw
    $hasValidAutoupdate = ($exCfg -match '"autoupdate"') -and ($setupPs1 -match '"autoupdate"')
    $noForbiddenUpdate = ($exCfg -notmatch '"update":') -and ($setupPs1 -notmatch '"update":')
    return ($hasValidAutoupdate -and $noForbiddenUpdate)
}

# 15. Batch launcher update forwarding and exit code fidelity test
Assert-Test "Batch launcher update forwarding and exit code fidelity" {
    powershell -NoProfile -ExecutionPolicy Bypass -File "$PortableRoot\scripts\update.ps1" -CheckOnly | Out-Null
    $expectedExitCode = $LASTEXITCODE

    $upOutput = cmd /c "`"$PortableRoot\opencode.bat`" update --check-only"
    $batExitCode = $LASTEXITCODE

    $codesMatch = ($batExitCode -eq $expectedExitCode)
    $hasBanner = ($upOutput -match "Checking for Updates")
    return ($codesMatch -and $hasBanner)
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
if ($PassedTests -eq $TotalTests) {
    Write-Host "  RESULT: ALL TESTS PASSED SUCCESSFULLY ($PassedTests/$TotalTests)  " -ForegroundColor Green
} else {
    Write-Host "  RESULT: SOME TESTS FAILED ($PassedTests/$TotalTests)  " -ForegroundColor Yellow
}
Write-Host "==========================================================`n" -ForegroundColor Cyan

exit ($TotalTests - $PassedTests)


