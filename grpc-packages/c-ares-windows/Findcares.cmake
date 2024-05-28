#
# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
# 
# SPDX-License-Identifier: Apache-2.0 OR MIT
#
#

# the following is like an include guard
set(TARGET_WITH_NAMESPACE "3rdParty::c-ares")
if (TARGET ${TARGET_WITH_NAMESPACE})
    return()
endif()

# note that we mimic the behavior or the Findgrpc.cmake that ships with CMake.
# as such, we declare several variables that other 3rdParty Packages which call
# find_package(c-ares) might be expecting even if O3DE itself does not use them.
# this allows the c-ares package we make to be usable as a drop in replacement
# for other third parties that want to use this c-ares - all you need to do is
# set your CMAKE_MODULE_PATH to the place this package lives and then 
# calls to find_package(c-ares) will result in this one being used.

# variables required from Findjsbim.cmake in CMake source:

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(CARES_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/c-ares/lib/debug)
        set(CARES_LIBRARY 
            ${CARES_LIBRARY_DIR}/cares.lib)        
    else()
        set(CARES_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/c-ares/lib/release)
        set(CARES_LIBRARY 
            ${CARES_LIBRARY_DIR}/cares.lib)           
    endif()


endif()

set(CARES_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR}/c-ares/include)
set(CARES_INCLUDE_DIR ${CARES_INCLUDE_DIRS})

set(CARES_VERSION_STRING "1.28.1")
set(CARES_VERSION_MAJOR "1")
set(CARES_VERSION_MINOR "28")
set(CARES_VERSION_PATCH "1")
set(CARES_MAJOR_VERSION "1")
set(CARES_MINOR_VERSION "28")
set(CARES_PATCH_VERSION "1")
set(CARES_FOUND True)

# declare the targets - O3DE has the 3rdParty namespace target, CMake has c-ares::c-ares
add_library(${TARGET_WITH_NAMESPACE} INTERFACE IMPORTED GLOBAL)

# cmake < 3.21 and visual studio < 16.10 don't properly implement SYSTEM includes
# so we use O3DEs patched implementation if it is available and fallback to default if not.
if (COMMAND ly_target_include_system_directories)
    ly_target_include_system_directories(TARGET ${TARGET_WITH_NAMESPACE} INTERFACE ${CARES_INCLUDE_DIR})
else()
    target_include_directories(${TARGET_WITH_NAMESPACE} SYSTEM INTERFACE ${CARES_INCLUDE_DIR})
endif()

target_link_libraries(${TARGET_WITH_NAMESPACE} INTERFACE ${CARES_LIBRARY})

# set the library file as the imported location so that things know to link to it:

# ly_add_target_files(TARGETS ${TARGET_WITH_NAMESPACE} FILES ${CARES_SHARE_LIBRARIES_RELEASE})

# if we're not in O3DE, it's also extremely helpful to show a message to logs that indicate that this
# library was successfully picked up, as opposed to the system one.
# A good way to know if you're in O3DE or not is that O3DE sets various cache variables before 
# calling find_package, specifically, LY_VERSION_ENGINE_NAME is always set very early:
if (NOT LY_VERSION_ENGINE_NAME)
    message(STATUS "Using the O3DE version of the c-ares library from ${CMAKE_CURRENT_LIST_DIR}")
endif()
