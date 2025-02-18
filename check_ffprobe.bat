@echo off
setlocal

REM Check if ffprobe is installed
ffprobe -version >nul 2>&1
if errorlevel 1 (
    echo ffprobe is not installed or not in the system path.
    exit /b 1
)

echo ffprobe is installed and available in the system path.
endlocal
