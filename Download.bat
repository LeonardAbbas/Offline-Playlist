@echo off
setlocal enabledelayedexpansion

yt-dlp -U

set "num=1"

for /f "delims=" %%a in ('type "videos_online.txt"') do (
    if not exist "temp\!num!.mp3" (
        echo Downloading !num! %%a
        yt-dlp https://www.youtube.com/watch?v=%%a -o "temp\!num!.mp3"
    )
    set /a num+=1
)

endlocal