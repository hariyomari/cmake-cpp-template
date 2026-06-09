@echo off

cd /d "%~dp0"
cd ..

:: Forces Ninja to re-evaulate the project (thinking all of the files have been changed) and generate a fresh compile_commands.json
if exist apps (
    for /r "src" %%i in (*.c) do copy /b "%%i"+,, "%%i" >nul 2>&1
)
if exist lib (
    for /r "lib" %%i in (*.c) do copy /b "%%i"+,, "%%i" >nul 2>&1
)

cmake --preset "windows"
cmake --build --preset "windows"
