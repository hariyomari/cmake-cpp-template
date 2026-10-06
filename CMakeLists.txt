#
# CMake configuration
#

cmake_minimum_required(VERSION 3.25.0)
project(cmake-c-cpp-project-template VERSION 2.0.0 LANGUAGES C CXX)

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

if(CMAKE_EXPORT_COMPILE_COMMANDS)
    add_custom_target(copy_compile_commands ALL
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_BINARY_DIR}/compile_commands.json"
            "${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json"
        COMMENT "Copied compile_commands.json to project root"
        VERBATIM
    )
endif()

# Build targets
add_custom_target(run
    COMMAND ${PROJECT_NAME}
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
    USES_TERMINAL)

#
# Dependencies
#

# Setting up dependencies goes here
# If you add a submodule via add_subdirectory(deps/foo), you can silence
# its warnings entirely by adding SYSTEM to its include directory mappings, like:
# target_include_directories(foo SYSTEM PUBLIC deps/foo/include)

#[===[
# Silence all dependency warnings
if(MSVC)
    target_compile_options(dep-name PRIVATE /w)
else()
    target_compile_options(dep-name PRIVATE -w)
endif()
#]===]

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
