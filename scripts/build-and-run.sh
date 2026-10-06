#!/bin/sh
# Builds the project, then runs it.
# Usage: scripts/build-and-run.sh [preset]
#   preset: a configure preset from CMakePresets.json (default: debug)
set -eu

preset="${1:-debug}"
script_dir="$(dirname -- "$0")"

sh "$script_dir/build.sh" "$preset"

cd "$script_dir/.."

# "run" is a custom target in CMakeLists.txt that runs the program from the build folder
if cmake --build --preset "$preset" --target run; then
    printf '\nApplication exited successfully.\n'
else
    printf '\nApplication exited with an error.\n'
    exit 1
fi
