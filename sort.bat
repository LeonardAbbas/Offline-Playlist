@echo off
setlocal enabledelayedexpansion

REM Moves all mp3 files into numbered folders with 256 files each.

echo Start sorting: %time%

for /r %%f in (*.mp3) do (
    set "name=%%~nf"
    call :removeLeadingZeros

    set "end=256"
    set "folder=1"
    call :findFolder

    if not exist "Music !folder!" mkdir "Music !folder!"
    move "%%f" "Music !folder!\%%~nxf" >nul
)

rmdir temp /q
echo End sorting: %time%

endlocal

:removeLeadingZeros
if "!name:~0,1!"=="0" (
    set "name=!name:~1!"
    goto :removeLeadingZeros
)
goto :eof

:findFolder
if !name! gtr !end! (
    set /a end+=256
    set /a folder+=1
    goto :findFolder
)
goto :eof