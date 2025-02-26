@echo off
setlocal

echo Getting videos: %time%

exiftool -T -FileName -Duration -Title temp\*.mp3 > videos_offline.txt
yt-dlp --flat-playlist --print title --print duration_string -I ::-1 > videos_online.txt

echo Finished getting videos: %time%

endlocal