#
# CMake configuration
#


# Minimum required CMake version
cmake_minimum_required(VERSION 3.25.0)

# Prevent building inside of the source directory
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "Build in a separate directory, e.g.: cmake --preset debug")
endif()

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

# Warning settings applied only to our own targets
add_library(project_config INTERFACE)
if(MSVC)
    target_compile_options(project_config INTERFACE /W4 /permissive- /utf-8)
    target_compile_definitions(project_config INTERFACE _CRT_SECURE_NO_WARNINGS)
else()
    target_compile_options(project_config INTERFACE -Wall -Wextra -Wpedantic -Wshadow -Wconversion)
endif()

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
endif()


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

# Common
set(COMMON_SRCS
    "src/common/clock.cpp"
    "src/common/error.cpp")
add_library(common STATIC ${COMMON_SRCS})
target_include_directories(common PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/src")
target_link_libraries(common PRIVATE project_config)

# Main
add_executable(${PROJECT_NAME} "src/main.cpp")
target_include_directories(${PROJECT_NAME} PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/src")
target_link_libraries(${PROJECT_NAME} PRIVATE project_config
    common)


#
# Project configuration
#

option(WARNINGS_AS_ERRORS "Fail the build on warnings in our code" OFF)
set_target_properties(${PROJECT_NAME} common PROPERTIES
    COMPILE_WARNING_AS_ERROR ${WARNINGS_AS_ERRORS})
