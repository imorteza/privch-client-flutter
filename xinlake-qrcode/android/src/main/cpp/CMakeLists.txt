# About to perform deeply recursive actions
if (NOT CMAKE_MAXIMUM_RECURSION_DEPTH)
    set(CMAKE_MAXIMUM_RECURSION_DEPTH 2000)
endif ()

# Sets the minimum version of CMake required to build the native library.
cmake_minimum_required(VERSION 3.14)

project("xinlake_qrcode")

# Force to build by C++17. The zxing-cpp require C++17 to build
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(BUILD_READERS ON)
set(BUILD_WRITERS OFF)

find_library(
    # Sets the name of the path variable.
    log-lib

    # Specifies the name of the NDK library that
    # you want CMake to locate.
    log
)

add_subdirectory(
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../../cpp/zxing-core"
    zxing-cpp
    EXCLUDE_FROM_ALL
)

add_library(
    xinlake-qrcode SHARED
    BarcodeReader.cpp
    JNIUtils.cpp
)

target_include_directories(xinlake-qrcode
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/../../../../cpp/stb"
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/../../../../cpp/zxing-core/src")

target_link_libraries(
    xinlake-qrcode PRIVATE
    ZXing
    log
    jnigraphics
)
