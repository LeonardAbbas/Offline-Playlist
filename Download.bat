@echo off
setlocal enabledelayedexpansion

cd ..

Offline-Playlist\yt-dlp -U

set "num=1"

for /f "delims=" %%a in ('type "Offline-Playlist\videos_online.txt"') do (
    if not exist "Music\!num!.mp3" (
        echo Downloading !num! %%a
        Offline-Playlist\yt-dlp https://www.youtube.com/watch?v=%%a -o "Music\!num!.mp3"
    )
    set /a num+=1
)

endlocal