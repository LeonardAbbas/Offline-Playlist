@echo off
setlocal enabledelayedexpansion

call unsort.bat
call videos.bat
call DownloadedVideos.bat
call DownloadNewVideos.bat

powershell.exe -ExecutionPolicy Bypass -File check_playlist.ps1

call DownloadMissingSongs.bat

del videos.txt
del DownloadedVideos.txt

call rename.bat
call sort.bat

endlocal
pause