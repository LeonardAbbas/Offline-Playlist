@echo off
setlocal

echo Getting videos: %time%

chcp 65001 >nul

yt-dlp --get-title --flat-playlist > videos.txt

echo Finished getting videos: %time%

endlocal