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

endlocal