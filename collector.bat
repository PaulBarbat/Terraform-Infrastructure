@echo off
setlocal enabledelayedexpansion

REM Usage: collector.bat <project_name> <file_pattern1> [file_pattern2] ...
REM Example: collector.bat Terraform-Infrastructure *.tf *.sh

if "%~1"=="" (
    echo Usage: %~nx0 ^<project_name^> ^<file_pattern1^> [file_pattern2...]
    exit /b 1
)

set "PROJECT=%~1"
shift

if not exist "%PROJECT%" (
    echo Error: Project directory "%PROJECT%" does not exist.
    exit /b 1
)

set "OUTPUT=collected_%PROJECT%.txt"
echo. > "%OUTPUT%"

:nextpattern
if "%~1"=="" goto done

set "PATTERN=%~1"
echo Processing pattern %PATTERN%...

for /r "%PROJECT%" %%F in (%PATTERN%) do (
    echo This is from %%F>>"%OUTPUT%"
    type "%%F">>"%OUTPUT%"
    echo.>>"%OUTPUT%"
    echo.>>"%OUTPUT%"
)

shift
goto nextpattern

:done
echo Collected contents written to %OUTPUT%
endlocal
