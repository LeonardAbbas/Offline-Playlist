@echo off
setlocal

echo Getting videos: %time%

yt-dlp --get-title --flat-playlist > videos_online.txt
exiftool -T -FileName -Title temp\*.mp3 > videos_offline.txt

echo Finished getting videos: %time%

endlocal