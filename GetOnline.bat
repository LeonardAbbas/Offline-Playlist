@echo off
yt-dlp --flat-playlist --print title --print duration_string -I ::-1 > videos_online.txt