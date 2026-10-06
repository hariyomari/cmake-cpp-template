@echo off
:: Builds the project, then runs it.
:: Usage: scripts\build-and-run.bat [preset]
::   preset: a configure preset from CMakePresets.json (default: debug)
setlocal

set "PRESET=%~1"
if "%PRESET%"=="" set "PRESET=debug"

call "%~dp0common.bat" || goto :build_failed
cd /d "%~dp0.." || goto :build_failed

cmake --preset "%PRESET%" || goto :build_failed
cmake --build --preset "%PRESET%" || goto :build_failed

:: "run" is a custom target in CMakeLists.txt that runs the program from the build folder
cmake --build --preset "%PRESET%" --target run
set "EXIT_CODE=%ERRORLEVEL%"
echo.
if %EXIT_CODE% neq 0 (echo Application exited with an error.) else (echo Application exited successfully.)
goto :done

:build_failed
set "EXIT_CODE=%ERRORLEVEL%"
echo Build failed with exit code %EXIT_CODE%.

:done
if defined DOUBLE_CLICKED pause
exit /b %EXIT_CODE%
