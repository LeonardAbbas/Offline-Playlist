@echo off
setlocal

echo Getting videos: %time%

exiftool -T -FileName -Title temp\*.mp3 > videos_offline.txt
yt-dlp --flat-playlist --print title -I ::-1 > videos_online.txt

echo Finished getting videos: %time%

endlocal