@echo off
setlocal enabledelayedexpansion

call unsort.bat
call get_videos.bat
call download_new_videos.bat

powershell.exe -ExecutionPolicy Bypass -File check_playlist.ps1

call download_missing_videos.bat

del videos_offline.txt
del videos_online.txt

call rename.bat
call sort.bat

endlocal
pause