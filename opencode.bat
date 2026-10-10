@echo off
setlocal

REM 1. Detect host Windows Terminal (wt.exe) before any environment redirection
set "WT_BIN="
if exist "%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe" set "WT_BIN=%LOCALAPPDATA%\Microsoft\WindowsApps\wt.exe"
if not defined WT_BIN (
    where wt.exe >nul 2>&1 && for /f "delims=" %%i in ('where wt.exe 2^>nul') do if not defined WT_BIN set "WT_BIN=%%i"
)

REM 2. Detect if execution must remain in-place (CLI flags, CI, or test scripts)
set "FORCE_INPLACE=0"
if /i "%~1"=="--no-wt" set "FORCE_INPLACE=1"
if /i "%~1"=="--version" set "FORCE_INPLACE=1"
if /i "%~1"=="-v" set "FORCE_INPLACE=1"
if /i "%~1"=="--help" set "FORCE_INPLACE=1"
if /i "%~1"=="-h" set "FORCE_INPLACE=1"
if /i "%~1"=="update" set "FORCE_INPLACE=1"
if /i "%~1"=="--update" set "FORCE_INPLACE=1"
if /i "%~2"=="--no-wt" set "FORCE_INPLACE=1"
if /i "%~3"=="--no-wt" set "FORCE_INPLACE=1"
if /i "%~4"=="--no-wt" set "FORCE_INPLACE=1"
if /i "%~5"=="--no-wt" set "FORCE_INPLACE=1"
if /i "%~6"=="--no-wt" set "FORCE_INPLACE=1"
if /i "%~7"=="--no-wt" set "FORCE_INPLACE=1"
if /i "%~8"=="--no-wt" set "FORCE_INPLACE=1"
if /i "%~9"=="--no-wt" set "FORCE_INPLACE=1"
if defined OPENCODE_NO_WT set "FORCE_INPLACE=1"
if defined CI set "FORCE_INPLACE=1"
if defined GITHUB_ACTIONS set "FORCE_INPLACE=1"

REM 3. If interactive and not inside Windows Terminal, spawn Windows Terminal or PowerShell
if "%FORCE_INPLACE%"=="0" if not defined WT_SESSION (
    if defined WT_BIN (
        start "" "%WT_BIN%" --title "OpenCode Portable" -d "%~dp0." powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0opencode.ps1" %*
        exit /b 0
    )
    start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0opencode.ps1" %*
    exit /b 0
)


REM 4. Load isolated portable environment
call "%~dp0scripts\env.bat"

REM Handle update subcommand
if /i "%~1"=="update" goto :RUN_LAUNCHER
if /i "%~1"=="--update" goto :RUN_LAUNCHER

REM Check if opencode.exe exists
if not exist "%PORTABLE_ROOT%\bin\opencode.exe" (
    echo.
    echo =======================================================================
    echo  [OpenCode Portable] First run detected
    echo =======================================================================
    echo  Official OpenCode v2 executable not found in:
    echo  %PORTABLE_ROOT%\bin\opencode.exe
    echo.
    echo  Starting automatic download and bootstrap of OpenCode v2...
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\scripts\setup.ps1"
    if not exist "%PORTABLE_ROOT%\bin\opencode.exe" (
        echo.
        echo [ERROR] Could not complete OpenCode v2 installation.
        echo Please check your internet connection and try again.
        pause
        exit /b 1
    )
    echo.
    echo Installation completed successfully. Launching OpenCode...
    echo.
)

:RUN_LAUNCHER
REM Run through PowerShell launcher to ensure full UTF-8 console encoding
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\opencode.ps1" %*
exit /b %ERRORLEVEL%



