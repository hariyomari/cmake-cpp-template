@echo off
setlocal enabledelayedexpansion

for /f "tokens=2 delims=()" %%a in ('findstr /i "project(" ..\CMakeLists.txt') do (
    for %%b in (%%a) do (
        set "PROJECT_NAME=%%b"
        goto :found_name
    )
)
:found_name
echo Building project: %PROJECT_NAME%

cd /d "%~dp0"

set "BUILD_SCRIPT=build.bat"
if not exist "%BUILD_SCRIPT%" (
    echo Failed to find the build script; exiting.
    call :exit_with_code 1
)
call "%BUILD_SCRIPT%"
if %errorlevel% neq 0 call :exit_with_code %errorlevel%

:: Move to the build directory so our output binary can detect files relative to its current path 
cd ..\build || call :exit_with_code 1

set "OUTPUT_BINARY=windows\%PROJECT_NAME%.exe"
if not exist "%OUTPUT_BINARY%" (
    echo Failed to find the output binary; exiting.
    call :exit_with_code 1
)

"%OUTPUT_BINARY%"
echo.
call :exit_with_code %errorlevel%

:exit_with_code
set "EXIT_CODE=%~1"
if %EXIT_CODE% neq 0 (
    echo Application exited with an error: %EXIT_CODE%
    pause
) else (
    echo Application exited successfully: %EXIT_CODE%
    pause
)

exit /b %EXIT_CODE%
