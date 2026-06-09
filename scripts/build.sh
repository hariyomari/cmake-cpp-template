#!/bin/sh

cd "${0%/*}" || exit
cd ..

cmake --preset "gnu-linux"
cmake --build --preset "gnu-linux"
