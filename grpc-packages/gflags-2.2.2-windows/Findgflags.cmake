#
# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
# 
# SPDX-License-Identifier: Apache-2.0 OR MIT
#
#

# the following is like an include guard
set(TARGET_WITH_NAMESPACE "3rdParty::gflags")
if (TARGET ${TARGET_WITH_NAMESPACE})
    return()
endif()

# note that we mimic the behavior or the Findgrpc.cmake that ships with CMake.
# as such, we declare several variables that other 3rdParty Packages which call
# find_package(gflags) might be expecting even if O3DE itself does not use them.
# this allows the gflags package we make to be usable as a drop in replacement
# for other third parties that want to use this gflags - all you need to do is
# set your CMAKE_MODULE_PATH to the place this package lives and then 
# calls to find_package(gflags) will result in this one being used.

# variables required from Findjsbim.cmake in CMake source:

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(GFLAGS_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/gflags/lib/debug)
        set(GFLAGS_LIBRARY 
            ${GFLAGS_LIBRARY_DIR}/gflags_debug.lib)
    else()
        set(GFLAGS_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/gflags/lib/release)
        set(GFLAGS_LIBRARY 
            ${GFLAGS_LIBRARY_DIR}/gflags.lib)        
    endif()


endif()

set(GFLAGS_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR}/gflags/include)
set(GFLAGS_INCLUDE_DIR ${GFLAGS_INCLUDE_DIRS})

set(GFLAGS_VERSION_STRING "2.2.2")
set(GFLAGS_VERSION_MAJOR "2")
set(GFLAGS_VERSION_MINOR "2")
set(GFLAGS_VERSION_PATCH "2")
set(GFLAGS_MAJOR_VERSION "2")
set(GFLAGS_MINOR_VERSION "2")
set(GFLAGS_PATCH_VERSION "2")
set(GFLAGS_FOUND True)

# declare the targets - O3DE has the 3rdParty namespace target, CMake has gflags::gflags
add_library(${TARGET_WITH_NAMESPACE} INTERFACE IMPORTED GLOBAL)

# cmake < 3.21 and visual studio < 16.10 don't properly implement SYSTEM includes
# so we use O3DEs patched implementation if it is available and fallback to default if not.
if (COMMAND ly_target_include_system_directories)
    ly_target_include_system_directories(TARGET ${TARGET_WITH_NAMESPACE} INTERFACE ${GFLAGS_INCLUDE_DIR})
else()
    target_include_directories(${TARGET_WITH_NAMESPACE} SYSTEM INTERFACE ${GFLAGS_INCLUDE_DIR})
endif()

target_link_libraries(${TARGET_WITH_NAMESPACE} INTERFACE ${GFLAGS_LIBRARY})

# set the library file as the imported location so that things know to link to it:

# ly_add_target_files(TARGETS ${TARGET_WITH_NAMESPACE} FILES ${GFLAGS_SHARE_LIBRARIES_RELEASE})

# if we're not in O3DE, it's also extremely helpful to show a message to logs that indicate that this
# library was successfully picked up, as opposed to the system one.
# A good way to know if you're in O3DE or not is that O3DE sets various cache variables before 
# calling find_package, specifically, LY_VERSION_ENGINE_NAME is always set very early:
if (NOT LY_VERSION_ENGINE_NAME)
    message(STATUS "Using the O3DE version of the gflags library from ${CMAKE_CURRENT_LIST_DIR}")
endif()
