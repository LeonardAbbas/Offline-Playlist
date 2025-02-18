@echo off
setlocal enabledelayedexpansion

set "songsInPlaylist=0"
for /f "delims=" %%a in ('type "videos.txt"') do (
    set /a songsInPlaylist+=1
)

for /L %%i in (1,1,!songsInPlaylist!) do (
    set "num=0000%%i"
    set "num=!num:~-4!"
    if not exist "temp\!num!.mp3" (
        echo Downloading !num!
        yt-dlp -I %%i
    )
)

endlocal