@echo off
setlocal

chcp 65001 >nul

yt-dlp --get-title --flat-playlist > videos.txt

endlocal