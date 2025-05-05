@echo off

echo Adjusting gain: %time%
cd ..
Offline-Playlist\mp3gain /r /c /q Music\*.mp3 > nul