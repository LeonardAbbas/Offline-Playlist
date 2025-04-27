@echo off

echo Getting offline videos: %time%

cd ..
Offline-Playlist\exiftool -T -filename -title -purl Music\*.mp3 > Offline-Playlist\videos_offline.txt
cd Offline-Playlist