cmake_minimum_required(VERSION 3.16)
project(prefab-cpp-client VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set build type to Release if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Compiler-specific options
set(CMAKE_CXX_FLAGS "-Wall -Wextra")
set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

# Find required packages
find_package(PkgConfig REQUIRED)
find_package(CURL REQUIRED)

# Try to find nlohmann_json
find_package(nlohmann_json 3.2.0 QUIET)
if(NOT nlohmann_json_FOUND)
    message(STATUS "nlohmann_json not found, will use FetchContent")
    include(FetchContent)
    FetchContent_Declare(
        nlohmann_json
        URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz
    )
    FetchContent_MakeAvailable(nlohmann_json)
endif()

# Check for DNS-SD support (for mDNS discovery)
# On Raspberry Pi, this might require Avahi development packages
pkg_check_modules(AVAHI_CLIENT avahi-client)
if(AVAHI_CLIENT_FOUND)
    add_definitions(-DHAVE_AVAHI=1)
endif()

# Include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Source files
set(SOURCES
    src/client.cpp
)

# Header files
set(HEADERS
    include/prefab/models.h
    include/prefab/client.h
    include/prefab/prefab.h
)

# Create the library
add_library(prefab-client STATIC ${SOURCES} ${HEADERS})

# Set target properties
set_target_properties(prefab-client PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    PUBLIC_HEADER "${HEADERS}"
)

# Link libraries
target_link_libraries(prefab-client 
    PRIVATE 
        CURL::libcurl
        nlohmann_json::nlohmann_json
)

# Add Avahi libraries if available
if(AVAHI_CLIENT_FOUND)
    target_link_libraries(prefab-client PRIVATE ${AVAHI_CLIENT_LIBRARIES})
    target_include_directories(prefab-client PRIVATE ${AVAHI_CLIENT_INCLUDE_DIRS})
    target_compile_options(prefab-client PRIVATE ${AVAHI_CLIENT_CFLAGS_OTHER})
endif()

# Include directories for the target
target_include_directories(prefab-client
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

# Installation
include(GNUInstallDirs)

install(TARGETS prefab-client
    EXPORT prefab-client-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/prefab
)

install(EXPORT prefab-client-targets
    FILE prefab-client-targets.cmake
    NAMESPACE prefab::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/prefab-client
)

# Create a config file
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/prefab-client-config-version.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/prefab-client-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/prefab-client-config.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/prefab-client
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/prefab-client-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/prefab-client-config-version.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/prefab-client
)

# Example programs (optional)
option(BUILD_EXAMPLES "Build example programs" ON)
if(BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

# Tests (optional)
option(BUILD_TESTS "Build tests" ON)
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Print configuration summary
message(STATUS "")
message(STATUS "Prefab C++ Client Configuration Summary:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  C++ standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  CURL found: ${CURL_FOUND}")
message(STATUS "  nlohmann_json found: ${nlohmann_json_FOUND}")
message(STATUS "  Avahi support: ${AVAHI_CLIENT_FOUND}")
message(STATUS "  Build examples: ${BUILD_EXAMPLES}")
message(STATUS "  Build tests: ${BUILD_TESTS}")
message(STATUS "")