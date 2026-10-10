@echo off
setlocal
call "%~dp0scripts\env.bat"

echo.
echo =======================================================================
echo          OpenCode Portable - Official Updater (v2)
echo =======================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\scripts\update.ps1" %*

if %ERRORLEVEL% neq 0 (
    echo.
    echo [NOTICE] Process exited with code %ERRORLEVEL%.
)

echo.
if "%~1"=="" pause
exit /b %ERRORLEVEL%
