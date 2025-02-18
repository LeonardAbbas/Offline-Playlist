@echo off
setlocal disabledelayedexpansion

echo Getting downloaded videos: %time%

if exist "downloaded-videos.txt" del "downloaded-videos.txt"

for /f "tokens=*" %%t in ('dir /b /o:n /a:-d "temp\*.mp3"') do (
    for /f "usebackq delims=" %%a in (`ffprobe -v error -show_entries format_tags^=title -of default^=noprint_wrappers^=1:nokey^=1 "temp\%%t"`) do (
        echo %%~nxt: %%a>> "downloaded-videos.txt"
    )
)

echo Finished getting downloaded videos: %time%
endlocal