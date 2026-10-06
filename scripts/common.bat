@echo off
:: Shared setup for the other Windows scripts, so you don't need to run this yourself.
::
:: 1. Sets DOUBLE_CLICKED=1 if the script was started from Explorer, so the
::    calling script knows to pause before its window closes.
:: 2. If MSVC isn't available in this terminal, finds Visual Studio and loads its
::    environment (the same thing "Developer PowerShell" does). This makes the
::    scripts work from any terminal, not just a Developer one.
:: 3. Checks that CMake and Ninja are installed.
::
:: There is no setlocal here on purpose, as the variables set below need to stay
:: visible to the script that called this one.

:: Explorer starts scripts as: cmd.exe /c ""C:\path\script.bat" "
:: That trailing quote-space-quote doesn't appear when run from a terminal.
:: The quotes are swapped for underscores because comparing quotes in batch is unreliable.
set "DOUBLE_CLICKED="
set "CMD_TAIL=%CMDCMDLINE:~-3%"
set "CMD_TAIL=%CMD_TAIL:"=_%"
if "%CMD_TAIL%"=="_ _" set "DOUBLE_CLICKED=1"

:: Already in a Developer terminal (or MSVC is on PATH some other way)
where cl >nul 2>nul && goto :check_tools

:: vswhere ships with every Visual Studio install since 2017, always at this path
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" goto :check_tools

set "VS_PATH="
for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -property installationPath`) do set "VS_PATH=%%i"
if not defined VS_PATH goto :check_tools
if not exist "%VS_PATH%\VC\Auxiliary\Build\vcvarsall.bat" goto :check_tools

set "VS_ARCH=x64"
if /i "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "VS_ARCH=arm64"
:: vcvarsall.bat calls vswhere by name, so it needs to be on PATH too
set "PATH=%PATH%;%ProgramFiles(x86)%\Microsoft Visual Studio\Installer"
call "%VS_PATH%\VC\Auxiliary\Build\vcvarsall.bat" %VS_ARCH% >nul

:check_tools
where cmake >nul 2>nul || (echo CMake was not found. Install it from https://cmake.org/download/ & exit /b 1)
where ninja >nul 2>nul || (echo Ninja was not found. Install it with: winget install Ninja-build.Ninja & exit /b 1)
exit /b 0
