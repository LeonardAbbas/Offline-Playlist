@echo off
setlocal enabledelayedexpansion

call unsort.bat

chcp 65001 >nul

set "songsDownloaded=0"

for %%f in ("Music 1\*.mp3") do (
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

yt-dlp -U

:download_loop
if %songsDownloaded% lss %songsInPlaylist% (
    echo Downloading videos %songsDownloaded% to %songsInPlaylist%
    yt-dlp PLLrZ_MgFFAB_yF8QNecKLEmBiVfXM4L2H -I %songsDownloaded%:%songsInPlaylist%
    set /a songsDownloaded+=100
    goto :download_loop
)

for /f "tokens=*" %%b in ('dir /b /on "Music 1\*.mp3"') do (
    ffprobe -v error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 -i "Music 1\%%b" > temp.txt
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
    if not exist "Music 1\!num!.mp3" (
        echo Downloading !num!
        yt-dlp PLLrZ_MgFFAB_yF8QNecKLEmBiVfXM4L2H -I %%i
    )
)

del temp.txt

call rename.bat
call sort.bat

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
            if exist "Music 1\!num!.mp3" del "Music 1\!num!.mp3"
            ren "Music 1\!filepath!" "!num!.mp3"
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