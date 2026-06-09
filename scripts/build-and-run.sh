#!/bin/sh

cd "${0%/*}" || exit

build_script=./build.sh
if [ ! -f ${build_script} ]; then
    echo "Failed to find the build script; exiting."
    exit 1
fi
eval ${build_script}

# Move to the build directory so our output binary can detect files relative to its current path 
cd ../build || exit

output_binary=./linux/main
if [ ! -f ${output_binary} ]; then
    echo "Failed to find the output binary; exiting."
    exit 1
fi

eval ${output_binary}
exit_code=$?
if [ ${exit_code} -ne 0 ]; then
    echo "Application exited with an error: ${exit_code}"
    exit ${exit_code}
fi

exit 0
