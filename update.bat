@echo off
setlocal enabledelayedexpansion

call unsort.bat
call get_videos.bat

powershell.exe -ExecutionPolicy Bypass -File check_playlist.ps1

call download_videos.bat

del videos_offline.txt
del videos_offline_channels.txt
del videos_online.txt
del videos_online_channels.txt

call sort.bat

endlocal
pause