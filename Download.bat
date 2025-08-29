@echo off
setlocal enabledelayedexpansion

cd ..

Offline-Playlist\yt-dlp -U

set "num=1"

for /f "delims=" %%a in ('type "Offline-Playlist\videos_online.txt"') do (
    set "padded_num=0000!num!"
    set "padded_num=!padded_num:~-4!"
    if not exist "Music\!padded_num!.mp3" (
        echo Downloading !padded_num! %%a
        Offline-Playlist\yt-dlp https://www.youtube.com/watch?v=%%a -o "Music\!padded_num!.mp3"
    )
    set /a num+=1
)

endlocal