# The file editing part of setup. Editing a file isn't practical in batch,
# so init.bat and init.sh both use this. You don't need to run it yourself.
#
# Each part only runs if its variables are passed in:
#   -D NAME=my-project                    renames the project in CMakeLists.txt, resets its
#                                         version to 0.1.0, and writes a new README.md
#   -D LICENSE=MIT -D AUTHOR="Your Name"  writes LICENSE from setup/licenses/MIT.txt, filling in
#                                         the author and current year if it has a copyright line.
#                                         LICENSE=none deletes LICENSE instead.
#   -D DRY_RUN=1                          prints what would change instead
# Usage: cmake -D NAME=my-project -P setup/init.cmake

set(root "${CMAKE_CURRENT_LIST_DIR}/..")

if(DEFINED NAME)
    # The project name is also used as the executable and target name, so keep it to
    # characters that are safe in file names on every system.
    if(NOT NAME MATCHES "^[A-Za-z0-9_-]+$")
        message(FATAL_ERROR "\"${NAME}\" can't be used as a project name, use only letters, numbers, - and _")
    endif()

    file(READ "${root}/CMakeLists.txt" contents)

    # Find the project line, e.g. project(cmake-cpp-template VERSION 2.0.0 LANGUAGES C CXX)
    string(REGEX MATCH "project\\([^)]*\\)" old_line "${contents}")
    if(NOT old_line)
        message(FATAL_ERROR "Couldn't find the project(...) line in CMakeLists.txt")
    endif()

    # Only the project line is changed, so cmake_minimum_required(VERSION ...) is left alone
    string(REGEX REPLACE "^project\\([^ \t\r\n)]+" "project(${NAME}" new_line "${old_line}")
    string(REGEX REPLACE "VERSION [0-9.]+" "VERSION 0.1.0" new_line "${new_line}")

    if(DRY_RUN)
        message("[dry run] change CMakeLists.txt to: ${new_line}")
    else()
        string(REPLACE "${old_line}" "${new_line}" contents "${contents}")
        file(WRITE "${root}/CMakeLists.txt" "${contents}")
        message("Changed CMakeLists.txt to: ${new_line}")
    endif()

    # The template's README is about the template, so start the new project with just a title
    if(DRY_RUN)
        message("[dry run] replace README.md with a new one titled \"${NAME}\"")
    else()
        file(WRITE "${root}/README.md" "# ${NAME}\n\nDescribe what ${NAME} does here.\n")
        message("Replaced README.md with a new one titled \"${NAME}\".")
    endif()
endif()

if(LICENSE STREQUAL "none")
    # No license means all rights reserved: others may look at the code, but not use it
    if(DRY_RUN)
        message("[dry run] delete LICENSE")
    else()
        file(REMOVE "${root}/LICENSE")
        message("Deleted LICENSE. The project is now all rights reserved.")
    endif()
elseif(DEFINED LICENSE)
    set(license_template "${CMAKE_CURRENT_LIST_DIR}/licenses/${LICENSE}.txt")
    if(NOT EXISTS "${license_template}")
        message(FATAL_ERROR "There's no license template for \"${LICENSE}\" in setup/licenses/")
    endif()

    # configure_file copies the template and replaces @YEAR@ and @AUTHOR@ with these variables.
    # Licenses without a copyright line (like GPL) are copied unchanged.
    string(TIMESTAMP YEAR "%Y")
    set(description "${LICENSE}")
    if(AUTHOR)
        string(APPEND description ", copyright ${YEAR} ${AUTHOR}")
    endif()

    if(DRY_RUN)
        message("[dry run] replace LICENSE with ${description}")
    else()
        configure_file("${license_template}" "${root}/LICENSE" @ONLY)
        message("Replaced LICENSE with ${description}.")
    endif()
endif()
