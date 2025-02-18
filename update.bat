@echo off
setlocal enabledelayedexpansion

call unsort.bat
call get-videos.bat
call download-new-videos.bat

powershell.exe -ExecutionPolicy Bypass -File check_playlist.ps1

call download-missing-videos.bat

del videos.txt
del downloaded-videos.txt

call rename.bat
call sort.bat

endlocal
pause