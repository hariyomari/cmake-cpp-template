#!/bin/sh
# Configures and builds the project.
# Usage: scripts/build.sh [preset]
#   preset: a configure preset from CMakePresets.json (default: debug)
set -eu

preset="${1:-debug}"

for tool in cmake ninja; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "error: $tool was not found. Install it with your package manager." >&2
        exit 1
    fi
done

cd "$(dirname -- "$0")/.."

cmake --preset "$preset"
cmake --build --preset "$preset"
