@echo off
setlocal
call "%~dp0scripts\env.bat"

powershell -NoProfile -ExecutionPolicy Bypass -File "%PORTABLE_ROOT%\scripts\test.ps1"

echo.
pause
exit /b %ERRORLEVEL%

