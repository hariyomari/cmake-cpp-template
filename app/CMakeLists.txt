# Common
set(COMMON_SRCS
    "src/common/clock.cpp"
    "src/common/error.cpp")


# Binary executable
add_executable(${PROJECT_NAME} "src/main.cpp"
    ${COMMON_SRCS})
target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/src")
target_link_libraries(${PROJECT_NAME} PRIVATE 
    cmake_config)
