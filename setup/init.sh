#!/bin/sh
# Sets up a new project made from this template. It is meant to be run once, right after cloning the template.
# Usage: setup/init.sh [--dry-run]
#   --dry-run: print the commands that would change something instead of running them
#
# 1. Renames the project in CMakeLists.txt, resets its version to 0.1.0,
#    and replaces README.md with a short one titled with the project's name.
# 2. Replaces LICENSE with the license you choose, with your name and the current year.
# 3. Deletes the existing git history (after asking).
# 4. Runs git init with the branch name you choose.
# 5. Adds the remotes you enter. Every remote's URL is also added to "origin",
#    so "git push" pushes to all of them at once.
# 6. Optionally makes the first commit, pushes it, and deletes the setup folder.
set -eu

DRY_RUN=0
case "${1:-}" in
    "") ;;
    --dry-run) DRY_RUN=1 ;;
    # Stop on anything else, so a typo like --dryrun doesn't run the script for real
    *)
        echo "error: unknown option: $1" >&2
        echo "Usage: setup/init.sh [--dry-run]" >&2
        exit 1
        ;;
esac

if [ "$DRY_RUN" = 1 ]; then
    echo "Dry run: nothing will be changed."
fi

# Runs a command, or only prints it while dry running.
# Usage: run command [arguments...]
run() {
    if [ "$DRY_RUN" = 1 ]; then
        echo "[dry run] $*"
    else
        "$@"
    fi
}

# Prints "> " and reads one line into the variable named by $1.
# Usage: prompt variable_name
prompt() {
    printf '> '
    # read fails when there's no more input (Ctrl+D), so stop instead of asking forever
    read -r "$1" || exit 1
}

# Asks a yes/no question until it gets an answer. Pressing Enter picks the default.
# Usage: ask_yes_no "Question? [y/N]" default
# The letter in uppercase is representative of the default option, and this defaults to [y/N] (no) for destructive questions.
# Returns 0 for yes and 1 for no, so it works with if, && and ||.
ask_yes_no() {
    while :; do
        printf '%s ' "$1"
        read -r answer || exit 1
        case "${answer:-$2}" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
        esac
    done
}

for tool in git cmake; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "error: $tool was not found. Install it with your package manager." >&2
        exit 1
    fi
done

# Remember the script's full path before changing folders, so it can still be found later.
script_dir="$(cd -- "$(dirname -- "$0")" && pwd)"

# Move to the root directory.
cd "$script_dir/.."

echo "This will set up a new project in \"$PWD\"."

# If git is already initialized, warn the user that continuing will
# permanently delete the existing git history.
if [ -e .git ]; then
    commit_count="$(git rev-list --count --all 2>/dev/null || echo 0)"
    remotes_list="$(git remote | sort -r | paste -s -d , - | sed 's/,/, /g')"

    echo "The existing git history will be permanently deleted:"
    echo "- $commit_count commits, remotes: ${remotes_list:-none}"
fi

echo
if ! ask_yes_no "Continue? [y/N]" n; then
    echo "Cancelled. Nothing was changed."
    exit 1
fi

# The folder name is the default project name.
folder_name="$(basename -- "$PWD")"
while :; do
    echo
    echo "Project name (leave empty for \"$folder_name\"):"
    prompt project_name
    project_name="${project_name:-$folder_name}"

    # CMake checks the name, edits CMakeLists.txt and writes README.md. If the name isn't valid, ask again.
    if cmake -D "NAME=$project_name" -D "DRY_RUN=$DRY_RUN" -P "$script_dir/init.cmake"; then
        break
    fi
done

echo
echo "License (leave empty for MIT):"
echo "  1. MIT          - permissive: do anything, but keep the copyright notice"
echo "  2. Apache 2.0   - like MIT, plus protection against patent lawsuits"
echo "  3. BSD 3-Clause - like MIT, plus your name can't be used for promotion"
echo "  4. BSL 1.0      - like MIT, but compiled programs don't need the notice"
echo "  5. Zlib         - like BSL 1.0, plus changed source must be marked as changed"
echo "  6. 0BSD         - no conditions at all"
echo "  7. MPL 2.0      - weak copyleft: only changes to these files must stay open"
echo "  8. GPL 3.0      - copyleft: anything built from this code must be GPL too"
echo "  9. AGPL 3.0     - like GPL 3.0, and also covers software used over a network"
echo "  0. None         - all rights reserved: nobody else may use the code"
license=""
while [ -z "$license" ]; do
    prompt license_choice
    case "${license_choice:-1}" in
        1) license=MIT ;;
        2) license=Apache-2.0 ;;
        3) license=BSD-3-Clause ;;
        4) license=BSL-1.0 ;;
        5) license=Zlib ;;
        6) license=0BSD ;;
        7) license=MPL-2.0 ;;
        8) license=GPL-3.0 ;;
        9) license=AGPL-3.0 ;;
        0) license=none ;;
    esac
done

# Only ask for an author if the license has a copyright line to put it in
author=""
if [ "$license" != none ] && grep -q '@AUTHOR@' "$script_dir/licenses/$license.txt"; then
    # Your git name is the default author, if you've set one.
    default_author="$(git config user.name 2>/dev/null || true)"
    while [ -z "$author" ]; do
        echo
        if [ -n "$default_author" ]; then
            echo "Author name for the license (leave empty for \"$default_author\"):"
        else
            echo "Author name for the license:"
        fi
        prompt author
        author="${author:-$default_author}"
    done
fi

cmake -D "LICENSE=$license" -D "AUTHOR=$author" -D "DRY_RUN=$DRY_RUN" -P "$script_dir/init.cmake"

echo
if [ -e .git ]; then
    run rm -rf .git
fi

echo 'Default branch name (leave empty for "main"):'
prompt branch_name
branch_name="${branch_name:-main}"
run git init -b "$branch_name"

# Each remote is added under its own name, and its URL is also added to origin.
# Git fetches from origin's first URL, but pushes to all of them.
origin_added=0
while :; do
    echo
    echo "Remote name (leave empty when you're done):"
    prompt remote_name
    if [ -z "$remote_name" ]; then
        break
    fi

    remote_url=""
    while [ -z "$remote_url" ]; do
        echo "Remote URL:"
        prompt remote_url
    done

    if [ "$remote_name" != origin ]; then
        run git remote add "$remote_name" "$remote_url"
    fi
    if [ "$origin_added" = 0 ]; then
        run git remote add origin "$remote_url"
        origin_added=1
        echo "Added $remote_name as origin."
    else
        run git remote set-url --add origin "$remote_url"
    fi
done

# Asked here rather than at the end, so the setup folder can be left out of the first commit.
echo
delete_setup=0
if ask_yes_no "Delete the setup folder when finished? [Y/n]" y; then
    delete_setup=1
fi

echo
committed=0
if ask_yes_no "Commit everything? [Y/n]" y; then
    echo 'Commit message (leave empty for "all: init"):'
    prompt commit_message
    commit_message="${commit_message:-all: init}"

    # ':(exclude)...' tells git add to skip the files that are about to be deleted
    if [ "$delete_setup" = 1 ]; then
        run git add --all -- . ':(exclude)setup'
    else
        run git add --all
    fi
    run git commit -m "$commit_message"
    committed=1
fi

if [ "$committed" = 1 ] && [ "$origin_added" = 1 ]; then
    echo
    if ask_yes_no "Push to origin now? [Y/n]" y; then
        if ! run git push --set-upstream origin "$branch_name"; then
            # A normal push is rejected if the remote already has commits, for example
            # a README made when the repository was created on the website.
            echo
            echo "The push failed. If the remote already has commits, a force push replaces them with yours."
            if ask_yes_no "Force push? Everything already on the remote will be lost. [y/N]" n; then
                run git push --set-upstream --force origin "$branch_name"
            fi
        fi
    fi
fi

echo
echo "Finished setting up \"$PWD\"."

if [ "$delete_setup" = 1 ]; then
    # Unlike cmd, sh can safely delete the script it's running: the shell keeps
    # the file open, so it stays readable until the script ends.
    run rm -rf -- "$script_dir"
fi
