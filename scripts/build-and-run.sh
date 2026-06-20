#!/bin/sh

exit_with_code() {
    exit_code=$1

    if [ "${exit_code}" -ne 0 ]; then
        echo "Application exited with an error: ${exit_code}"
        read -r _
    else
        echo "Application exited successfully: ${exit_code}"
    fi

    exit "$exit_code"
}

cd "${0%/*}" || exit_with_code 1

project_name=$(grep -i "project(" ../CMakeLists.txt | head -n 1 | sed 's/.*project(\([A-Za-z0-9_-]*\).*/\1/i')
echo "Building project: ${project_name}";

build_script=./build.sh
if [ ! -f ${build_script} ]; then
    echo "Failed to find the build script; exiting."
    exit_with_code 1
fi

if ! eval ${build_script}; then
    exit_with_code 1;
fi

# Move to the build directory so our output binary can detect files relative to its current path 
cd ../build || exit

output_binary=./linux/${project_name}
if [ ! -f "${output_binary}" ]; then
    echo "Failed to find the output binary; exiting."
    exit_with_code 1
fi

eval "${output_binary}"
printf "\n"
exit_with_code $?
