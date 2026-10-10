@echo off
REM ============================================================================
REM OpenCode Portable Environment Setup
REM Total isolation for USB pendrive portable usage on Windows 10 & 11
REM ============================================================================

REM Get portable root directory (without trailing backslash)
set "PORTABLE_ROOT=%~dp0.."
for %%i in ("%PORTABLE_ROOT%") do set "PORTABLE_ROOT=%%~fi"

REM Ensure data and tools directories exist
if not exist "%PORTABLE_ROOT%\bin" mkdir "%PORTABLE_ROOT%\bin"
if not exist "%PORTABLE_ROOT%\tools" mkdir "%PORTABLE_ROOT%\tools"
if not exist "%PORTABLE_ROOT%\data\config\opencode" mkdir "%PORTABLE_ROOT%\data\config\opencode"
if not exist "%PORTABLE_ROOT%\data\config\opencode\skills" mkdir "%PORTABLE_ROOT%\data\config\opencode\skills"
if not exist "%PORTABLE_ROOT%\data\share\opencode" mkdir "%PORTABLE_ROOT%\data\share\opencode"
if not exist "%PORTABLE_ROOT%\data\cache\opencode" mkdir "%PORTABLE_ROOT%\data\cache\opencode"
if not exist "%PORTABLE_ROOT%\data\state\opencode" mkdir "%PORTABLE_ROOT%\data\state\opencode"
if not exist "%PORTABLE_ROOT%\data\logs" mkdir "%PORTABLE_ROOT%\data\logs"
if not exist "%PORTABLE_ROOT%\data\profile" mkdir "%PORTABLE_ROOT%\data\profile"
if not exist "%PORTABLE_ROOT%\data\appdata\roaming" mkdir "%PORTABLE_ROOT%\data\appdata\roaming"
if not exist "%PORTABLE_ROOT%\data\appdata\local" mkdir "%PORTABLE_ROOT%\data\appdata\local"
if not exist "%PORTABLE_ROOT%\data\temp" mkdir "%PORTABLE_ROOT%\data\temp"

REM Auto-create default configuration if not present
if not exist "%PORTABLE_ROOT%\data\config\opencode\opencode.jsonc" (
    if exist "%PORTABLE_ROOT%\data\config\opencode\opencode.example.jsonc" (
        copy /y "%PORTABLE_ROOT%\data\config\opencode\opencode.example.jsonc" "%PORTABLE_ROOT%\data\config\opencode\opencode.jsonc" >nul
    )
)

REM OpenCode v2 official environment variables
set "OPENCODE_CONFIG_DIR=%PORTABLE_ROOT%\data\config\opencode"
set "OPENCODE_DATA_DIR=%PORTABLE_ROOT%\data\share\opencode"
set "OPENCODE_CACHE_DIR=%PORTABLE_ROOT%\data\cache\opencode"
set "OPENCODE_STATE_DIR=%PORTABLE_ROOT%\data\state\opencode"
set "OPENCODE_LOG_DIR=%PORTABLE_ROOT%\data\logs"

REM XDG Base Directory specification
set "XDG_CONFIG_HOME=%PORTABLE_ROOT%\data\config"
set "XDG_DATA_HOME=%PORTABLE_ROOT%\data\share"
set "XDG_CACHE_HOME=%PORTABLE_ROOT%\data\cache"
set "XDG_STATE_HOME=%PORTABLE_ROOT%\data\state"

REM Isolated Windows user profile and AppData (never touch host C:\Users)
set "USERPROFILE=%PORTABLE_ROOT%\data\profile"
set "HOME=%PORTABLE_ROOT%\data\profile"
set "APPDATA=%PORTABLE_ROOT%\data\appdata\roaming"
set "LOCALAPPDATA=%PORTABLE_ROOT%\data\appdata\local"
set "TEMP=%PORTABLE_ROOT%\data\temp"
set "TMP=%PORTABLE_ROOT%\data\temp"

REM Isolate PowerShell module analysis cache from root
if not exist "%PORTABLE_ROOT%\data\cache\powershell" mkdir "%PORTABLE_ROOT%\data\cache\powershell"
set "PSModuleAnalysisCachePath=%PORTABLE_ROOT%\data\cache\powershell\ModuleAnalysisCache"

REM Git portable configuration
set "GIT_CONFIG_GLOBAL=%PORTABLE_ROOT%\data\config\.gitconfig"

REM Construct isolated PATH:
REM Priority: 1) bin, 2) portable tools (git, node), 3) Windows system32 only
set "PORTABLE_PATH=%PORTABLE_ROOT%\bin"
if exist "%PORTABLE_ROOT%\tools\git\cmd" set "PORTABLE_PATH=%PORTABLE_PATH%;%PORTABLE_ROOT%\tools\git\cmd"
if exist "%PORTABLE_ROOT%\tools\git\usr\bin" set "PORTABLE_PATH=%PORTABLE_PATH%;%PORTABLE_ROOT%\tools\git\usr\bin"
if exist "%PORTABLE_ROOT%\tools\git\bin" set "PORTABLE_PATH=%PORTABLE_PATH%;%PORTABLE_ROOT%\tools\git\bin"
if exist "%PORTABLE_ROOT%\tools\node" set "PORTABLE_PATH=%PORTABLE_PATH%;%PORTABLE_ROOT%\tools\node"

set "PATH=%PORTABLE_PATH%;%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"

chcp 65001 >nul 2>&1
set "PYTHONIOENCODING=utf-8"
set "LANG=en_US.UTF-8"
