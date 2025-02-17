@echo off
setlocal enabledelayedexpansion

for %%f in ("Music 1\*.mp3") do (
    if %%~nf lss 1000 (
        set "name=000%%~nf"
        set "name=!name:~-4!"
        ren "%%f" "!name!.mp3"
    )
)

endlocal