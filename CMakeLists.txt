#
# CMake configuration
#


# Minimum required CMake version
cmake_minimum_required(VERSION 3.25.0)


# Prevent building inside of the source directory
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "Build in a separate directory, e.g.: cmake --preset debug")
endif ()


# Project configuration
project(cmake-cpp-template VERSION 2.0.0 LANGUAGES C CXX)


# C++17, C++20, C++23, C++26
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


# C99, C17, C23
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)


# Build environment and compiler-specific flags
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


# AddressSanitizer for Debug builds
option(ENABLE_ASAN "Build Debug with AddressSanitizer" ON)
if (ENABLE_ASAN AND MSVC)
    # /RTC1 is in CMake's default MSVC Debug flags and is incompatible with ASan
    string(REPLACE "/RTC1" "" CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
    string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")

    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
    endif ()

    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_compile_options(/fsanitize=address)
    endif()
endif ()


# Project configuration options
option(WARNINGS_AS_ERRORS "Fail the build on warnings in our code" OFF)


# Project configuration interface library
add_library(cmake_config INTERFACE)
if (MSVC)
    target_compile_options(cmake_config INTERFACE /W4 /permissive- /utf-8)
    target_compile_definitions(cmake_config INTERFACE _CRT_SECURE_NO_WARNINGS)
    if (WARNINGS_AS_ERRORS)
        target_compile_options(cmake_config INTERFACE /WX)
    endif ()
else ()
    target_compile_options(cmake_config INTERFACE
            -Wall -Wextra -Wpedantic -Wshadow -Wconversion)
    if (WARNINGS_AS_ERRORS)
        target_compile_options(cmake_config INTERFACE -Werror)
    endif ()
endif ()


# Build targets
add_custom_target(run
    COMMAND ${PROJECT_NAME}
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
    USES_TERMINAL)


# Copy `compile_commands.json` to the root directory, so clangd can see it
if(PROJECT_IS_TOP_LEVEL AND CMAKE_GENERATOR MATCHES "Ninja|Makefiles")
    add_custom_target(copy_compile_commands ALL
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_BINARY_DIR}/compile_commands.json"
        "${CMAKE_SOURCE_DIR}/compile_commands.json")
endif ()


#
# Dependencies
#


# Setting up dependencies goes here - for each submodule:
#
# if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/deps/foo/CMakeLists.txt")
#     message(FATAL_ERROR "deps/foo is empty. Run: git submodule update --init --recursive")
# endif()
# add_subdirectory(deps/foo EXCLUDE_FROM_ALL SYSTEM)
# target_link_libraries(${PROJECT_NAME} PRIVATE foo)
#


#
# Project libraries
#


add_subdirectory(app)
