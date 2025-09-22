cmake_minimum_required(VERSION 3.15)
project(OpenRoot VERSION 0.1.0)

# Specify C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find dependencies using vcpkg
find_package(nlohmann_json CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)

# Add rootd executable
add_executable(rootd
    rootd/rootd.cc
)

# Link libraries
target_link_libraries(rootd PRIVATE
    nlohmann_json::nlohmann_json
    spdlog::spdlog
)

# Set include directories
target_include_directories(rootd PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Platform-specific settings
if(ANDROID)
    target_compile_definitions(rootd PRIVATE __ANDROID__)
elseif(UNIX)
    target_compile_definitions(rootd PRIVATE __LINUX__)
endif()

# Installation
install(TARGETS rootd
    RUNTIME DESTINATION bin
)

# Install configuration
install(FILES config/rootd.json
    DESTINATION etc/rootd
    RENAME config.json
)