#
# Master OpenCog Orchestration CMake file.
#
# This file orchestrates the build of all OpenCog components in proper
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

# CMake version requirement aligned with OpenCog core
CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

IF (COMMAND CMAKE_POLICY)
	CMAKE_POLICY(SET CMP0003 NEW)
ENDIF (COMMAND CMAKE_POLICY)

IF(CMAKE_VERSION VERSION_GREATER 3.0.2)
	CMAKE_POLICY(SET CMP0037 OLD)
ENDIF(CMAKE_VERSION VERSION_GREATER 3.0.2)

PROJECT(opencog-orchestration)

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

# Add the cmake directory to the module path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/")

# ----------------------------------------------------------
# Check for existance of various required, optional packages.

# Check for standard packages
FIND_PACKAGE(PkgConfig)

# CogUtil
FIND_PACKAGE(CogUtil 2.0.3 CONFIG REQUIRED)
IF (COGUTIL_FOUND)
    MESSAGE(STATUS "CogUtil found.")
    ADD_DEFINITIONS(-DHAVE_COGUTIL)
    SET(HAVE_COGUTIL 1)
ELSE (COGUTIL_FOUND)
    MESSAGE(FATAL_ERROR "CogUtil missing: it is needed!")
ENDIF (COGUTIL_FOUND)

# AtomSpace
FIND_PACKAGE(AtomSpace 5.0.4 CONFIG REQUIRED)
IF (ATOMSPACE_FOUND)
    MESSAGE(STATUS "AtomSpace found.")
    ADD_DEFINITIONS(-DHAVE_ATOMSPACE)
    SET(HAVE_ATOMSPACE 1)
ELSE (ATOMSPACE_FOUND)
    MESSAGE(FATAL_ERROR "AtomSpace missing: it is needed!")
ENDIF (ATOMSPACE_FOUND)

# ----------------------------------------------------------
# Check for optional packages

# Check for Guile
FIND_PACKAGE(Guile 3.0)
IF (GUILE_FOUND)
    ADD_DEFINITIONS(-DHAVE_GUILE)
    SET(HAVE_GUILE 1)
    SET(GUILE_INCLUDE_DIRS ${GUILE_INCLUDE_DIR})
    SET(GUILE_LIBRARIES ${GUILE_LIBRARY})
ENDIF (GUILE_FOUND)

# Check for Python
FIND_PACKAGE(Python3 COMPONENTS Interpreter Development)
IF (Python3_FOUND)
    ADD_DEFINITIONS(-DHAVE_PYTHON)
    SET(HAVE_PYTHON 1)
    SET(PYTHON_INCLUDE_DIRS ${Python3_INCLUDE_DIRS})
    SET(PYTHON_LIBRARIES ${Python3_LIBRARIES})
ENDIF (Python3_FOUND)

# Check for Cython
IF (Python3_FOUND)
    EXECUTE_PROCESS(
        COMMAND ${Python3_EXECUTABLE} -c "import Cython; print(Cython.__version__)"
        OUTPUT_VARIABLE CYTHON_VERSION
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    IF (CYTHON_VERSION)
        MESSAGE(STATUS "Cython found: version ${CYTHON_VERSION}")
        SET(HAVE_CYTHON 1)
    ENDIF (CYTHON_VERSION)
ENDIF (Python3_FOUND)

# Check for Neo4j dependencies
IF (Python3_FOUND)
    EXECUTE_PROCESS(
        COMMAND ${Python3_EXECUTABLE} -c "import neo4j; print('Neo4j driver found')"
        OUTPUT_VARIABLE NEO4J_CHECK
        ERROR_QUIET
    )
    IF (NEO4J_CHECK)
        MESSAGE(STATUS "Neo4j Python driver found")
        SET(HAVE_NEO4J_PYTHON 1)
    ENDIF (NEO4J_CHECK)
ENDIF (Python3_FOUND)

# Check for ROS (for robot embodiment)
FIND_PACKAGE(catkin QUIET)
IF (catkin_FOUND)
    MESSAGE(STATUS "ROS/catkin found")
    SET(HAVE_ROS 1)
ENDIF (catkin_FOUND)

# ----------------------------------------------------------
# Global C++ settings

SET(CMAKE_CXX_STANDARD 17)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)

# Compiler-specific C++17 flags
IF (CMAKE_COMPILER_IS_GNUCXX)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wno-unused-parameter")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-declarations")
    
    # Optimize
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -fomit-frame-pointer")
    SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -O2 -g")
    
    # Debug
    SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g3 -fstack-protector")
ENDIF (CMAKE_COMPILER_IS_GNUCXX)

# ----------------------------------------------------------
# Include configuration

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${COGUTIL_INCLUDE_DIR})
INCLUDE_DIRECTORIES(${ATOMSPACE_INCLUDE_DIR})

IF (GUILE_FOUND)
    INCLUDE_DIRECTORIES(${GUILE_INCLUDE_DIRS})
ENDIF (GUILE_FOUND)

IF (Python3_FOUND)
    INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_DIRS})
ENDIF (Python3_FOUND)

# ----------------------------------------------------------
# Decide what to build, based on the packages found.

# OpenCog Core (always built if dependencies are met)
IF (HAVE_COGUTIL AND HAVE_ATOMSPACE)
    SET(BUILD_OPENCOG_CORE 1)
    MESSAGE(STATUS "OpenCog Core will be built")
ENDIF (HAVE_COGUTIL AND HAVE_ATOMSPACE)

# Knowledge Systems
SET(BUILD_OPENCOG_CYCL 1)
MESSAGE(STATUS "OpenCog-Cycl integration will be built")

IF (HAVE_NEO4J_PYTHON)
    SET(BUILD_OPENCOG_NEO4J 1)
    MESSAGE(STATUS "OpenCog-Neo4j integration will be built")
ELSE (HAVE_NEO4J_PYTHON)
    MESSAGE(STATUS "OpenCog-Neo4j integration will NOT be built (missing Neo4j Python driver)")
ENDIF (HAVE_NEO4J_PYTHON)

# Integration Platforms
IF (HAVE_ROS)
    SET(BUILD_ROS_EMBODIMENT 1)
    MESSAGE(STATUS "ROS robot embodiment will be built")
ELSE (HAVE_ROS)
    MESSAGE(STATUS "ROS robot embodiment will NOT be built (missing ROS)")
ENDIF (HAVE_ROS)

SET(BUILD_MINECRAFT_INTEGRATION 1)
MESSAGE(STATUS "Minecraft integration will be built")

SET(BUILD_UNITY3D_INTEGRATION 1)
MESSAGE(STATUS "Unity3D integration will be built")

# Specialized Applications
SET(BUILD_RPI_SUPPORT 1)
MESSAGE(STATUS "Raspberry Pi support will be built")

SET(BUILD_WEBSITE_COMPONENTS 1)
MESSAGE(STATUS "Website components will be built")

# Deployment Packages
SET(BUILD_DEBIAN_PACKAGES 1)
MESSAGE(STATUS "Debian packaging will be built")

SET(BUILD_NIX_PACKAGES 1)
MESSAGE(STATUS "Nix packaging will be built")

# ----------------------------------------------------------
# Add subdirectories for components

# Core OpenCog
IF (BUILD_OPENCOG_CORE)
    IF (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/opencog/CMakeLists.txt")
        ADD_SUBDIRECTORY(opencog)
    ENDIF()
ENDIF (BUILD_OPENCOG_CORE)

# ----------------------------------------------------------
# Configuration summary

MESSAGE(STATUS "")
MESSAGE(STATUS "==========================================================")
MESSAGE(STATUS "OpenCog Orchestration build configuration summary:")
MESSAGE(STATUS "")
MESSAGE(STATUS "CMake version:          ${CMAKE_VERSION}")
MESSAGE(STATUS "CMake install prefix:   ${CMAKE_INSTALL_PREFIX}")
MESSAGE(STATUS "Build type:             ${CMAKE_BUILD_TYPE}")
MESSAGE(STATUS "")
MESSAGE(STATUS "CogUtil version:        ${COGUTIL_VERSION}")
MESSAGE(STATUS "AtomSpace version:      ${ATOMSPACE_VERSION}")
MESSAGE(STATUS "")

# Dependencies summary
MESSAGE(STATUS "Optional dependencies:")
IF (GUILE_FOUND)
    MESSAGE(STATUS "  Guile:                yes (${GUILE_VERSION})")
ELSE (GUILE_FOUND)
    MESSAGE(STATUS "  Guile:                no")
ENDIF (GUILE_FOUND)

IF (Python3_FOUND)
    MESSAGE(STATUS "  Python:               yes (${Python3_VERSION})")
ELSE (Python3_FOUND)
    MESSAGE(STATUS "  Python:               no")
ENDIF (Python3_FOUND)

IF (HAVE_CYTHON)
    MESSAGE(STATUS "  Cython:               yes (${CYTHON_VERSION})")
ELSE (HAVE_CYTHON)
    MESSAGE(STATUS "  Cython:               no")
ENDIF (HAVE_CYTHON)

IF (HAVE_NEO4J_PYTHON)
    MESSAGE(STATUS "  Neo4j Python:         yes")
ELSE (HAVE_NEO4J_PYTHON)
    MESSAGE(STATUS "  Neo4j Python:         no")
ENDIF (HAVE_NEO4J_PYTHON)

IF (HAVE_ROS)
    MESSAGE(STATUS "  ROS/catkin:           yes")
ELSE (HAVE_ROS)
    MESSAGE(STATUS "  ROS/catkin:           no")
ENDIF (HAVE_ROS)

MESSAGE(STATUS "")

# Components summary
MESSAGE(STATUS "Components to be built:")
MESSAGE(STATUS "  OpenCog Core:         ${BUILD_OPENCOG_CORE}")
MESSAGE(STATUS "  OpenCog-Cycl:         ${BUILD_OPENCOG_CYCL}")
MESSAGE(STATUS "  OpenCog-Neo4j:        ${BUILD_OPENCOG_NEO4J}")
MESSAGE(STATUS "  ROS Embodiment:       ${BUILD_ROS_EMBODIMENT}")
MESSAGE(STATUS "  Minecraft Integration:${BUILD_MINECRAFT_INTEGRATION}")
MESSAGE(STATUS "  Unity3D Integration:  ${BUILD_UNITY3D_INTEGRATION}")
MESSAGE(STATUS "  RPi Support:          ${BUILD_RPI_SUPPORT}")
MESSAGE(STATUS "  Website Components:   ${BUILD_WEBSITE_COMPONENTS}")
MESSAGE(STATUS "  Debian Packages:      ${BUILD_DEBIAN_PACKAGES}")
MESSAGE(STATUS "  Nix Packages:         ${BUILD_NIX_PACKAGES}")

MESSAGE(STATUS "==========================================================")
MESSAGE(STATUS "")
