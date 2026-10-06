# CMake C++ Template

A modern, lightweight boilerplate for starting new C++ projects with CMake. It starts as C++20, and C can be mixed in when needed. It builds on Windows and Linux.

## Requirements

- [CMake](https://cmake.org/download/) 3.25 or newer
- [Ninja](https://ninja-build.org/) (Windows: `winget install Ninja-build.Ninja`)
- A C++20 compiler: Visual Studio 2022 or its Build Tools on Windows, GCC 13+ or Clang 17+ on Linux
- [Git](https://git-scm.com/downloads)

## Getting started

Clone the template into a folder named after your project, then run the setup script:

```sh
git clone https://codeberg.org/hariyomari/cmake-cpp-template.git my-project
cd my-project
setup/init.sh                 # Windows: setup\init.bat
```

The script asks a few questions, then:

- renames the project and resets its version to 0.1.0
- replaces this README with a short one for your project
- replaces the license with one you pick from a list of common ones (MIT, Apache 2.0, GPL 3.0 and more), with your name and the current year
- replaces the template's git history with a fresh repository, and sets up your remotes
- optionally makes the first commit, pushes it, and deletes the `setup/` folder

Add `--dry-run` to see what it would do without changing anything.

## Building

```sh
scripts/build.sh              # Windows: scripts\build.bat
scripts/build-and-run.sh      # Windows: scripts\build-and-run.bat
```

Both build the `debug` preset by default. Pass `release` for an optimized build, e.g. `scripts/build.sh release`. The program ends up in `build/<preset>/bin/`.

On Windows, the scripts find Visual Studio for you, so they work from any terminal. To run CMake yourself, use a Developer PowerShell:

```sh
cmake --preset debug
cmake --build --preset debug
```

## Project layout

```
src/          source code
  main.cpp
  common/     example library, showing how to add and link a library of your own
deps/         dependencies, added as git submodules
scripts/      build scripts
setup/        one-time project setup, deleted after use
```

`common/` is only sample code, and `main.cpp` doesn't use it. To remove it, delete the folder and every line that mentions `common` in `CMakeLists.txt`.

## Adding a dependency

Add it as a submodule in `deps/`:

```sh
git submodule add https://github.com/example/foo.git deps/foo
```

Then link it in `CMakeLists.txt`. The commented example in the Dependencies section shows how.

Anyone cloning a project that has submodules needs `git clone --recursive`, or `git submodule update --init --recursive` after a normal clone.

## Editor setup

`.clangd` reads the compile commands from `build/debug`, so build the `debug` preset once before opening the project in an editor that uses clangd (VS Code with the clangd extension, Neovim, etc.).

## License

This template is licensed under [0BSD](LICENSE): use it for anything, without keeping the notice or crediting it. The setup script replaces it with your own project's license.
