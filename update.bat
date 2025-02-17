@echo off
setlocal enabledelayedexpansion

chcp 65001 >nul

call unsort.bat
call videos.bat

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
for /f "delims=" %%a in ('type "videos.txt"') do (
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

for /f "tokens=*" %%b in ('dir /b /on "temp\*.mp3"') do (
    ffprobe -v error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 -i "temp\%%b" > temp.txt
    for /f "delims=" %%c in ('type temp.txt') do (
        set "title=%%c"
    )
    set "filename=%%~nb"
    set "filepath=%%b"
    call :check_title
)


for /L %%i in (1,1,!songsInPlaylist!) do (
    set "num=0000%%i"
    set "num=!num:~-4!"
    if not exist "temp\!num!.mp3" (
        echo Downloading !num!
        yt-dlp -I %%i
    )
)

del temp.txt
del videos.txt

call rename.bat
call sort.bat

rmdir temp /q

endlocal
pause

:check_title
for /f "tokens=* delims=0" %%i in ("!filename!") do set "startLineNumber=%%i"

for /l %%i in (!startLineNumber!,-1,0) do (
    set /a skip=%%i-1
    call :getLine

    set "num=0000%%i"
    set "num=!num:~-4!"
    if /i "!line!"=="!title!" (
        set /a mod=%%i %% 100
        if !mod! == 0 (
            echo Found %%i
        ) 

        if not "!filename!"=="!num!" (
            if exist "temp\!num!.mp3" del "temp\!num!.mp3"
            ren "temp\!filepath!" "!num!.mp3"
        )
        goto :check_title_end
    )
)

echo Song !startLineNumber! not found in playlist: !title!
:check_title_end
goto :eof

:getLine
if !skip! leq 0 (
    for /f "tokens=*" %%a in ('type "videos.txt"') do (
        set "line=%%a"
        goto :eof
    )
) else (
    for /f "tokens=* skip=%skip%" %%a in ('type "videos.txt"') do (
        set "line=%%a"
        goto :eof
    )
)