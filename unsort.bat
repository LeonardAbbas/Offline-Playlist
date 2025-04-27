@echo off
setlocal enabledelayedexpansion

echo Start unsorting: %time%

cd ..

if not exist "Music" mkdir "Music"

for /r %%f in (*.mp3) do for %%a in ("%%f\..") do if not "%%~nxa"=="Music" move "%%f" "Music" >nul   