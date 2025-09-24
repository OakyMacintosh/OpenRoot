cmake_minimum_required(VERSION 3.22.1)
project(rootd)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Include directories
include_directories(${CMAKE_SOURCE_DIR}/../../../../include)

# Add rootd library
add_library(rootd SHARED
    ${CMAKE_SOURCE_DIR}/../../../../rootd/rootd.cc
)

# Find and link against log library (for Android logging)
find_library(log-lib log)
target_link_libraries(rootd ${log-lib})