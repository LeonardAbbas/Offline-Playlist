@echo off
setlocal enabledelayedexpansion

echo Start unsorting: %time%

if not exist "temp" mkdir "temp"

for /r %%f in (*.mp3) do move "%%f" "temp" >nul

echo End unsorting: %time%