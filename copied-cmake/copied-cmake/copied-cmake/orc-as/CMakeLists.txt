#
# Master AtomSpace Orchestration CMake file.
#
# This file orchestrates the build of all AtomSpace components in proper
# dependency order to ensure stable, correct operation.
#
# General organization:
# -- check for different compilers, OS'es
# -- search for various required & optional libraries/tools
# -- decide what to build based on above results.
# -- configure various config files.
# -- build components in dependency order
# -- print pretty summary
#

# CMake version requirement aligned with atomspace core
CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

IF (COMMAND CMAKE_POLICY)
	CMAKE_POLICY(SET CMP0003 NEW)
ENDIF (COMMAND CMAKE_POLICY)

IF(CMAKE_VERSION VERSION_GREATER 3.0.2)
	CMAKE_POLICY(SET CMP0037 OLD)
ENDIF(CMAKE_VERSION VERSION_GREATER 3.0.2)

PROJECT(atomspace-orchestration)

# ----------------------------------------------------------
# User-modifiable options. Feel free to change these!
#
# uncomment to be in Release mode [default]
# SET(CMAKE_BUILD_TYPE Release)

# uncomment to build in debug mode
# SET(CMAKE_BUILD_TYPE Debug)

# uncomment to be in coverage testing mode
# SET(CMAKE_BUILD_TYPE Coverage)

# uncomment to build in profile mode
# SET(CMAKE_BUILD_TYPE Profile)

# uncomment to build in release mode with debug information
# SET(CMAKE_BUILD_TYPE RelWithDebInfo)

# default build type
IF (CMAKE_BUILD_TYPE STREQUAL "")
	SET(CMAKE_BUILD_TYPE Release)
ENDIF (CMAKE_BUILD_TYPE STREQUAL "")

MESSAGE(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

ADD_DEFINITIONS(-DPROJECT_SOURCE_DIR="${CMAKE_SOURCE_DIR}"
                -DPROJECT_BINARY_DIR="${CMAKE_BINARY_DIR}")

# ===============================================================
# AtomSpace Components Build Order
#
# Components are built in dependency order to ensure proper installation
# 1. atomspace (core) - base dependency for all others
# 2. atomspace-rocks - basic persistent storage
# 3. atomspace-bridge - SQL bridge functionality  
# 4. atomspace-cog - network distributed storage
# 5. atomspace-restful - REST API interface
# 6. atomspace-rpc - RPC interface
# 7. atomspace-websockets - WebSocket interface
# 8. atomspace-agents - agents using above interfaces
# 9. atomspace-dht - distributed hash table functionality
# 10. atomspace-ipfs - IPFS integration
# 11. atomspace-metta - MeTTa language integration
# 12. atomspace-explorer - UI/exploration tools
# 13. atomspace-js - JavaScript bindings
# 14. atomspace-typescript - TypeScript bindings

MESSAGE(STATUS "Building AtomSpace Orchestration - all components")

# Core AtomSpace - Required foundation
IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace (core)")
    ADD_SUBDIRECTORY(atomspace)
ELSE()
    MESSAGE(WARNING "atomspace core not found - this is required!")
ENDIF()

# Storage backends
IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-rocks/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-rocks (RocksDB storage)")
    ADD_SUBDIRECTORY(atomspace-rocks)
ENDIF()

IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-bridge/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-bridge (SQL bridge)")
    ADD_SUBDIRECTORY(atomspace-bridge)
ENDIF()

# Network interfaces
IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-cog/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-cog (network storage)")
    ADD_SUBDIRECTORY(atomspace-cog)
ENDIF()

IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-restful/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-restful (REST API)")
    ADD_SUBDIRECTORY(atomspace-restful)
ENDIF()

IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-rpc/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-rpc (RPC interface)")
    ADD_SUBDIRECTORY(atomspace-rpc)
ENDIF()

IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-websockets/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-websockets (WebSocket interface)")
    ADD_SUBDIRECTORY(atomspace-websockets)
ENDIF()

# Agent systems
IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-agents/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-agents (agent systems)")
    ADD_SUBDIRECTORY(atomspace-agents)
ENDIF()

# Distributed and advanced storage
IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-dht/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-dht (distributed hash table)")
    ADD_SUBDIRECTORY(atomspace-dht)
ENDIF()

IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-ipfs/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-ipfs (IPFS integration)")
    ADD_SUBDIRECTORY(atomspace-ipfs)
ENDIF()

# Language integrations
IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-metta/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-metta (MeTTa integration)")
    ADD_SUBDIRECTORY(atomspace-metta)
ENDIF()

# UI and exploration tools
IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-explorer/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-explorer (exploration tools)")
    ADD_SUBDIRECTORY(atomspace-explorer)
ENDIF()

# Language bindings (built last as they may depend on multiple components)
IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-js/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-js (JavaScript bindings)")
    ADD_SUBDIRECTORY(atomspace-js)
ENDIF()

IF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/atomspace-typescript/CMakeLists.txt")
    MESSAGE(STATUS "Adding atomspace-typescript (TypeScript bindings)")
    ADD_SUBDIRECTORY(atomspace-typescript)
ENDIF()

# ===================================================================
# Show a summary of what was built

MESSAGE(STATUS "")
MESSAGE(STATUS "========================================")
MESSAGE(STATUS "AtomSpace Orchestration Build Summary")
MESSAGE(STATUS "========================================")
MESSAGE(STATUS "All available AtomSpace components have been configured.")
MESSAGE(STATUS "Components will be built in dependency order.")
MESSAGE(STATUS "Use 'make' to build all components.")
MESSAGE(STATUS "Use 'make install' to install all components.")
MESSAGE(STATUS "========================================")
MESSAGE(STATUS "")