@echo off
:: Sets up a new project made from this template. It is meant to be run once, right after cloning the template.
:: Usage: setup\init.bat [--dry-run]
::   --dry-run: print the commands that would change something instead of running them
::
:: 1. Renames the project in CMakeLists.txt, resets its version to 0.1.0,
::    and replaces README.md with a short one titled with the project's name.
:: 2. Replaces LICENSE with the license you choose, with your name and the current year.
:: 3. Deletes the existing git history (after asking).
:: 4. Runs git init with the branch name you choose.
:: 5. Adds the remotes you enter. Every remote's URL is also added to "origin",
::    so "git push" pushes to all of them at once.
:: 6. Optionally makes the first commit, pushes it, and deletes the setup folder.
setlocal

set "DRY_RUN=0"
if /i "%~1"=="--dry-run" set "DRY_RUN=1"
:: Stop on anything else, so a typo like --dryrun doesn't run the script for real
if "%DRY_RUN%"=="0" if not "%~1"=="" (
    echo Unknown option: %~1
    echo Usage: setup\init.bat [--dry-run]
    goto :failed
)

:: While dry running, %RUN% prints the command after it instead of running it
set "RUN="
if "%DRY_RUN%"=="1" set "RUN=echo [dry run]"
if "%DRY_RUN%"=="1" echo Dry run: nothing will be changed.

where git >nul 2>nul || (echo Git was not found. Install it from https://git-scm.com/downloads & goto :failed)
where cmake >nul 2>nul || (echo CMake was not found. Install it from https://cmake.org/download/ & goto :failed)

:: Move to the root directory.
cd /d "%~dp0.." || goto :failed

echo This will set up a new project in "%cd%".
if not exist .git goto :confirm_initialize

:: Git is already initialized, so warn the user that continuing will
:: permanently delete the existing git history.
set "commit_count=0"
for /f "delims=" %%c in ('git rev-list --count --all 2^>nul') do set "commit_count=%%c"

:: The full path to sort makes sure Windows' sort is used, not the Linux one Git Bash adds to PATH.
set "remotes_list="
for /f "delims=" %%r in ('git remote ^| %SystemRoot%\System32\sort.exe /R') do call :append_remote "%%r"
if not defined remotes_list set "remotes_list=none"

echo The existing git history will be permanently deleted:
echo - %commit_count% commits, remotes: %remotes_list%

:confirm_initialize
echo.
call :ask_yes_no "Continue? [y/N]" n || goto :cancelled

:: The folder name is the default project name.
for %%i in ("%cd%") do set "folder_name=%%~nxi"

:ask_project_name
echo.
echo Project name (leave empty for "%folder_name%"):
set "project_name="
set /p "project_name=> "
if not defined project_name set "project_name=%folder_name%"

:: CMake checks the name, edits CMakeLists.txt and writes README.md. If the name isn't valid, ask again.
cmake -D "NAME=%project_name%" -D "DRY_RUN=%DRY_RUN%" -P "%~dp0init.cmake" || goto :ask_project_name

:ask_license
echo.
echo License (leave empty for MIT):
echo   1. MIT          - permissive: do anything, but keep the copyright notice
echo   2. Apache 2.0   - like MIT, plus protection against patent lawsuits
echo   3. BSD 3-Clause - like MIT, plus your name can't be used for promotion
echo   4. BSL 1.0      - like MIT, but compiled programs don't need the notice
echo   5. Zlib         - like BSL 1.0, plus changed source must be marked as changed
echo   6. 0BSD         - no conditions at all
echo   7. MPL 2.0      - weak copyleft: only changes to these files must stay open
echo   8. GPL 3.0      - copyleft: anything built from this code must be GPL too
echo   9. AGPL 3.0     - like GPL 3.0, and also covers software used over a network
echo   0. None         - all rights reserved: nobody else may use the code
set "license_choice="
set /p "license_choice=> "
if not defined license_choice set "license_choice=1"
set "license="
if "%license_choice%"=="1" set "license=MIT"
if "%license_choice%"=="2" set "license=Apache-2.0"
if "%license_choice%"=="3" set "license=BSD-3-Clause"
if "%license_choice%"=="4" set "license=BSL-1.0"
if "%license_choice%"=="5" set "license=Zlib"
if "%license_choice%"=="6" set "license=0BSD"
if "%license_choice%"=="7" set "license=MPL-2.0"
if "%license_choice%"=="8" set "license=GPL-3.0"
if "%license_choice%"=="9" set "license=AGPL-3.0"
if "%license_choice%"=="0" set "license=none"
if not defined license goto :ask_license

:: Only ask for an author if the license has a copyright line to put it in
set "author="
if "%license%"=="none" goto :write_license
findstr /c:"@AUTHOR@" "%~dp0licenses\%license%.txt" >nul || goto :write_license

:: Your git name is the default author, if you've set one.
set "default_author="
for /f "delims=" %%n in ('git config user.name 2^>nul') do set "default_author=%%n"
set "author_hint="
if defined default_author set "author_hint= (leave empty for "%default_author%")"

:ask_author
echo.
echo Author name for the license%author_hint%:
set "author="
set /p "author=> "
if not defined author set "author=%default_author%"
if not defined author goto :ask_author

:write_license
cmake -D "LICENSE=%license%" -D "AUTHOR=%author%" -D "DRY_RUN=%DRY_RUN%" -P "%~dp0init.cmake" || goto :failed

echo.
if exist .git %RUN% rmdir /s /q .git
if "%DRY_RUN%"=="0" if exist .git (echo Could not delete .git. Is another program using it? & goto :failed)

echo Default branch name (leave empty for "main"):
set "branch_name="
set /p "branch_name=> "
if not defined branch_name set "branch_name=main"
%RUN% git init -b "%branch_name%" || goto :failed

:: Each remote is added under its own name, and its URL is also added to origin.
:: Git fetches from origin's first URL, but pushes to all of them.
set "origin_added=0"

:ask_remote_name
echo.
echo Remote name (leave empty when you're done):
set "remote_name="
set /p "remote_name=> "
if not defined remote_name goto :ask_delete_setup

:ask_remote_url
echo Remote URL:
set "remote_url="
set /p "remote_url=> "
if not defined remote_url goto :ask_remote_url

if /i not "%remote_name%"=="origin" (
    %RUN% git remote add "%remote_name%" "%remote_url%" || goto :failed
)
if "%origin_added%"=="0" (
    %RUN% git remote add origin "%remote_url%" || goto :failed
    set "origin_added=1"
    echo Added %remote_name% as origin.
) else (
    %RUN% git remote set-url --add origin "%remote_url%" || goto :failed
)
goto :ask_remote_name

:ask_delete_setup
:: Asked here rather than at the end, so the setup folder can be left out of the first commit.
echo.
set "delete_setup=0"
call :ask_yes_no "Delete the setup folder when finished? [Y/n]" y && set "delete_setup=1"

echo.
call :ask_yes_no "Commit everything? [Y/n]" y || goto :finish

echo Commit message (leave empty for "all: init"):
set "commit_message="
set /p "commit_message=> "
if not defined commit_message set "commit_message=all: init"

:: ":(exclude)..." tells git add to skip the files that are about to be deleted
if "%delete_setup%"=="1" (
    %RUN% git add --all -- . ":(exclude)setup" || goto :failed
) else (
    %RUN% git add --all || goto :failed
)
%RUN% git commit -m "%commit_message%" || goto :failed

if "%origin_added%"=="0" goto :finish
echo.
call :ask_yes_no "Push to origin now? [Y/n]" y || goto :finish
%RUN% git push --set-upstream origin "%branch_name%" && goto :finish

:: A normal push is rejected if the remote already has commits, for example
:: a README made when the repository was created on the website.
echo.
echo The push failed. If the remote already has commits, a force push replaces them with yours.
call :ask_yes_no "Force push? Everything already on the remote will be lost. [y/N]" n || goto :finish
%RUN% git push --set-upstream --force origin "%branch_name%" || goto :failed

:finish
echo.
echo Finished setting up "%cd%".
pause
if "%delete_setup%"=="1" goto :delete_setup
exit /b 0

:delete_setup
:: cmd reads a batch file line by line while running it, so a script that deletes
:: itself normally ends with a "batch file cannot be found" error. "(goto)" makes
:: the script end first; the rest of this line has already been read, so it still runs.
:: Ending the script also undoes its cd (because of setlocal), so it moves out of the
:: setup folder again first: Windows can't delete a folder a program is working in.
(goto) 2>nul & cd /d "%~dp0.." & %RUN% rmdir /s /q "%~dp0" 2>nul & if "%DRY_RUN%"=="0" if exist "%~dp0" echo The setup folder couldn't be deleted, probably because a terminal is open in it. You can delete it yourself.

:cancelled
echo Cancelled. Nothing was changed.
pause
exit /b 1

:failed
echo.
echo Stopped because of the error above.
pause
exit /b 1


:: Adds a remote name to remotes_list, with a comma between names.
:: Usage: call :append_remote "name"
:append_remote
if defined remotes_list (set "remotes_list=%remotes_list%, %~1") else (set "remotes_list=%~1")
exit /b 0

:: Asks a yes/no question until it gets an answer. Pressing Enter picks the default.
:: Usage: call :ask_yes_no "Question? [y/N]" default
:: The letter in uppercase is representative of the default option, and this defaults to [y/N] (no) for destructive questions.
:: Exits with 0 for yes and 1 for no, so it works with && and ||.
:ask_yes_no
set "answer="
set /p "answer=%~1 "
if not defined answer set "answer=%~2"
if /i "%answer%"=="y" exit /b 0
if /i "%answer%"=="n" exit /b 1
goto :ask_yes_no
