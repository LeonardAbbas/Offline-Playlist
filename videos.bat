@echo off
setlocal

chcp 65001 >nul

yt-dlp PLLrZ_MgFFAB_yF8QNecKLEmBiVfXM4L2H --get-title --flat-playlist --extractor-args youtube:lang=af

endlocal
pause