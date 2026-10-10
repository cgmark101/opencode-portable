@echo off
setlocal

REM Detect host Windows Terminal (wt.exe) before any environment redirection
set "WT_BIN="
if exist "%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe" set "WT_BIN=%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe"
if not defined WT_BIN (
    where wt.exe >nul 2>&1 && for /f "delims=" %%i in ('where wt.exe 2^>nul') do if not defined WT_BIN set "WT_BIN=%%i"
)

if not defined WT_SESSION (
    if defined WT_BIN (
        start "" "%WT_BIN%" --title "OpenCode Portable Shell" -d "%~dp0." powershell.exe -NoProfile -NoExit -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; & '%~dp0scripts\env.bat'; Write-Host '=======================================================================' -ForegroundColor Cyan; Write-Host '         OpenCode Portable Environment Shell (Windows 10/11)' -ForegroundColor Cyan; Write-Host '=======================================================================' -ForegroundColor Cyan; Write-Host ' - OpenCode, Git Portable, and Node Portable loaded in PATH' -ForegroundColor Gray; Write-Host ' - Environment, HOME, and AppData isolated to USB data' -ForegroundColor Gray; Write-Host '=======================================================================`n' -ForegroundColor Cyan; Write-Host 'Type opencode to launch the interactive TUI or exit to quit.`n' -ForegroundColor Yellow"
        exit /b 0
    )
    start "" powershell.exe -NoProfile -NoExit -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; & '%~dp0scripts\env.bat'; Write-Host '=======================================================================' -ForegroundColor Cyan; Write-Host '         OpenCode Portable Environment Shell (Windows 10/11)' -ForegroundColor Cyan; Write-Host '=======================================================================' -ForegroundColor Cyan; Write-Host ' - OpenCode, Git Portable, and Node Portable loaded in PATH' -ForegroundColor Gray; Write-Host ' - Environment, HOME, and AppData isolated to USB data' -ForegroundColor Gray; Write-Host '=======================================================================`n' -ForegroundColor Cyan; Write-Host 'Type opencode to launch the interactive TUI or exit to quit.`n' -ForegroundColor Yellow"
    exit /b 0
)

call "%~dp0scripts\env.bat"


echo =======================================================================
echo          OpenCode Portable Environment Shell (Windows 10/11)
echo =======================================================================
echo  - OpenCode, Git Portable, and Node Portable loaded in PATH
echo  - Environment, HOME, and AppData isolated to: %PORTABLE_ROOT%\data
echo =======================================================================
echo.

powershell.exe -NoProfile -NoExit -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; Write-Host 'Type opencode to launch the interactive TUI or exit to quit.`n' -ForegroundColor Yellow"

