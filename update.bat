@echo off
setlocal enabledelayedexpansion

echo Started updating: %time%

start "" /B yt-dlp --flat-playlist --print title --print duration_string -I ::-1 > videos_online.txt
call unsort.bat
start "" /B exiftool -T -FileName -Duration -Title temp\*.mp3 > videos_offline.txt

:: Wait for exiftool to finish
:wait_exiftool
tasklist /FI "IMAGENAME eq exiftool.exe" 2>NUL | find /I /N "exiftool.exe">NUL
if "%ERRORLEVEL%"=="0" (
    timeout /T 1 /NOBREAK > NUL
    goto wait_exiftool
)

:: Wait for yt-dlp to finish
:wait_ytdlp
tasklist /FI "IMAGENAME eq yt-dlp.exe" 2>NUL | find /I /N "yt-dlp.exe">NUL
if "%ERRORLEVEL%"=="0" (
    timeout /T 1 /NOBREAK > NUL
    goto wait_ytdlp
)

echo Starting to check playlist: %time%

powershell.exe -ExecutionPolicy Bypass -File check_playlist.ps1

call download_videos.bat

del videos_offline.txt
del videos_online.txt

@REM call sort.bat

echo Finished updating: %time%

endlocal