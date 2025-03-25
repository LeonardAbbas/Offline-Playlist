@echo off
setlocal enabledelayedexpansion

echo Started updating: %time%

start "" /b GetOnline.bat
call Unsort.bat
start "" /b GetOffline.bat

:wait_ytdlp
tasklist /FI "IMAGENAME eq yt-dlp.exe" 2>NUL | find /I /N "yt-dlp.exe">NUL
if "%ERRORLEVEL%"=="0" (
    goto wait_ytdlp
)

:wait_exiftool
tasklist /FI "IMAGENAME eq exiftool.exe" 2>NUL | find /I /N "exiftool.exe">NUL
if "%ERRORLEVEL%"=="0" (
    goto wait_exiftool
)

echo Starting to check playlist: %time%

powershell.exe -ExecutionPolicy Bypass -File check_playlist.ps1

call Download.bat

del videos_offline.txt
del videos_online.txt

echo Finished updating: %time%

endlocal