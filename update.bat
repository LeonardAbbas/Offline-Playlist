@echo off
setlocal enabledelayedexpansion

call Unsort.bat

call GetOffline.bat
call GetOnline.bat

echo Starting to check playlist: %time%

powershell.exe -ExecutionPolicy Bypass -File check_playlist.ps1

call Download.bat

del videos_offline.txt
del videos_online.txt

call AdjustGain.bat

echo Finished updating: %time%

endlocal