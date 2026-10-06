@echo off
:: Configures and builds the project.
:: Usage: scripts\build.bat [preset]
::   preset: a configure preset from CMakePresets.json (default: debug)
setlocal

set "PRESET=%~1"
if "%PRESET%"=="" set "PRESET=debug"

call "%~dp0common.bat" || goto :done
cd /d "%~dp0.." || goto :done

cmake --preset "%PRESET%" || goto :done
cmake --build --preset "%PRESET%" || goto :done

:done
set "EXIT_CODE=%ERRORLEVEL%"
if %EXIT_CODE% neq 0 echo Build failed with exit code %EXIT_CODE%.
if defined DOUBLE_CLICKED pause
exit /b %EXIT_CODE%
