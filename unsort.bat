@echo off
setlocal enabledelayedexpansion

REM moves all mp3 files from all subfolders into "Music 1" folder

echo Start unsorting: %time%

if not exist "Music 1" mkdir "Music 1"

for /r %%f in (*.mp3) do move "%%f" "Music 1" >nul

echo End unsorting: %time%