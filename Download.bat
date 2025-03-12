@echo off
setlocal enabledelayedexpansion

yt-dlp -U

set "num=1"

for /f "delims=" %%a in ('type "videos_online.txt"') do (
    set "name=0000!num!"
    set "name=!name:~-4!"
    if not exist "temp\!name!.mp3" (
        echo Downloading !name! %%a
        yt-dlp %%a -o "temp\!name!.mp3"
    )
    set /a num+=1
)

endlocal