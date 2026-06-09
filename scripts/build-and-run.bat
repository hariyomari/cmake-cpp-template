@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

set "BUILD_SCRIPT=build.bat"
if not exist "%BUILD_SCRIPT%" (
    echo Failed to find the build script; exiting.
    exit /b 1
)
call "%BUILD_SCRIPT%"

:: Move to the build directory so our output binary can detect files relative to its current path 
cd ..\build || exit /b 1

set "OUTPUT_BINARY=windows\main.exe"
if not exist "%OUTPUT_BINARY%" (
    echo Failed to find the output binary; exiting.
    exit /b 1
)

"%OUTPUT_BINARY%"
set "EXIT_CODE=%errorlevel%"
if %EXIT_CODE% neq 0 (
    echo Application exited with an error: %EXIT_CODE%
    pause
    exit /b %EXIT_CODE%
)

exit /b 0
