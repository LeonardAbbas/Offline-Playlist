@echo off
setlocal enabledelayedexpansion

echo Start unsorting: %time%

if not exist "temp" mkdir "temp"

for /r %%f in (*.mp3) do for %%a in ("%%f\..") do if not "%%~nxa"=="temp" move "%%f" "temp" >nul   

echo End unsorting: %time%