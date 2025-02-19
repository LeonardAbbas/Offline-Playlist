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
echo Songs in playlist: %songsInPlaylist%

:download_loop
if %songsDownloaded% lss %songsInPlaylist% (
    echo Downloading videos %songsDownloaded% to %songsInPlaylist%
    yt-dlp -I %songsDownloaded%:%songsInPlaylist%
    set /a songsDownloaded+=100
    goto :download_loop
)

for /L %%i in (1,1,!songsInPlaylist!) do (
    set "num=0000%%i"
    set "num=!num:~-4!"
    if not exist "temp\!num!.mp3" (
        echo Downloading !num!
        yt-dlp -I %%i
        if %%i lss 1000 (
            ren "temp\%%i.mp3" "!num!.mp3"
        )
    )
)

endlocal