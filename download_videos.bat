@echo off
setlocal enabledelayedexpansion

set "songsDownloaded=0"

for /r %%f in (*.mp3) do (
    set "fileNumber=%%~nf"
    set "fileNumber=!fileNumber:~-4!"
    if !fileNumber! gtr !songsDownloaded! (
        set "songsDownloaded=!fileNumber!"
    )
)

echo Songs downloaded: %songsDownloaded%

set "songsInPlaylist=0"
for /f "delims=" %%a in ('type "videos_online.txt"') do (
    set /a songsInPlaylist+=1
)
set /a songsInPlaylist=%songsInPlaylist/2
echo Songs in playlist: %songsInPlaylist%

set "start=1"

:download_loop
if !songsDownloaded! lss !songsInPlaylist! (
    set /a end=!songsInPlaylist!-!songsDownloaded!+1
    yt-dlp -I !start!:!end!
    set /a songsDownloaded+=100
    set /a start+=100
    goto :download_loop
)

for /L %%i in (1,1,!songsInPlaylist!) do (
    set "num=0000%%i"
    set "num=!num:~-4!"
    if not exist "temp\!num!.mp3" (
        echo Downloading !num!
        set /a num=!songsInPlaylist!-%%i+1
        yt-dlp -I !num!
    )
)

endlocal