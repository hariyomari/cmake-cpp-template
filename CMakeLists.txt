#
# CMake configuration
#

cmake_minimum_required(VERSION 3.10.0)
project(cmake-c-cpp-project-template VERSION 0.0.1 LANGUAGES C CXX)

# C++17, C++20, C++23
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# C99, C17, C23
set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Build environment and compiler-specific flags
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(MSVC)
    add_compile_options(/W4)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif() 

if(CMAKE_EXPORT_COMPILE_COMMANDS)
    add_custom_target(copy_compile_commands ALL
        COMMAND ${CMAKE_COMMAND} -E echo "hello"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_BINARY_DIR}/compile_commands.json"
            "${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json"
        COMMENT "Copied compile_commands.json to project root"
        VERBATIM
    )
endif()

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
    "src/common/time.c"
    "src/common/utils.c")
add_library(common STATIC ${COMMON_SRCS})
target_include_directories(common PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>)
target_link_libraries(common PUBLIC)

#
# Output binary
#

add_executable(${PROJECT_NAME} "src/main.c")
target_include_directories(${PROJECT_NAME} PRIVATE 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>)
target_link_libraries(${PROJECT_NAME} PRIVATE 
    common)
