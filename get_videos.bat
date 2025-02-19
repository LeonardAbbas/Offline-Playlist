@echo off
setlocal

echo Getting videos: %time%

exiftool -T -Artist temp\*.mp3 > videos_offline_channels.txt
exiftool -T -FileName -Title temp\*.mp3 > videos_offline.txt
yt-dlp --flat-playlist --print uploader > videos_online_channels.txt
yt-dlp --flat-playlist --print title > videos_online.txt

echo Finished getting videos: %time%

endlocal