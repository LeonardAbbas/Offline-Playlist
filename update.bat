@echo off
setlocal enabledelayedexpansion

call Unsort.bat
call GetOffline.bat
call GetOnline.bat
powershell.exe -ExecutionPolicy Bypass -File check_playlist.ps1
call Download.bat
del videos_offline.txt
del videos_online.txt
call AdjustGain.bat

endlocal