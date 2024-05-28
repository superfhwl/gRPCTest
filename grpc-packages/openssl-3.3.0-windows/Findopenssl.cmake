#
# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
# 
# SPDX-License-Identifier: Apache-2.0 OR MIT
#
#

# the following is like an include guard
set(TARGET_WITH_NAMESPACE "3rdParty::openssl")
if (TARGET ${TARGET_WITH_NAMESPACE})
    return()
endif()

# note that we mimic the behavior or the Findgrpc.cmake that ships with CMake.
# as such, we declare several variables that other 3rdParty Packages which call
# find_package(openssl) might be expecting even if O3DE itself does not use them.
# this allows the openssl package we make to be usable as a drop in replacement
# for other third parties that want to use this openssl - all you need to do is
# set your CMAKE_MODULE_PATH to the place this package lives and then 
# calls to find_package(openssl) will result in this one being used.

# variables required from Findjsbim.cmake in CMake source:

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(OPENSSL_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/openssl/lib/debug)
    else()
        set(OPENSSL_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/openssl/lib/release)
    endif()
    set(OPENSSL_LIBRARY 
        ${OPENSSL_LIBRARY_DIR}/libssl.lib
        ${OPENSSL_LIBRARY_DIR}/libcrypto.lib)       
endif()

set(OPENSSL_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR}/openssl/include)
set(OPENSSL_INCLUDE_DIR ${OPENSSL_INCLUDE_DIRS})

set(OPENSSL_VERSION_STRING "3.3.0")
set(OPENSSL_VERSION_MAJOR "3")
set(OPENSSL_VERSION_MINOR "3")
set(OPENSSL_VERSION_PATCH "0")
set(OPENSSL_MAJOR_VERSION "3")
set(OPENSSL_MINOR_VERSION "3")
set(OPENSSL_PATCH_VERSION "0")
set(OPENSSL_FOUND True)

# declare the targets - O3DE has the 3rdParty namespace target, CMake has openssl::openssl
add_library(${TARGET_WITH_NAMESPACE} INTERFACE IMPORTED GLOBAL)

# cmake < 3.21 and visual studio < 16.10 don't properly implement SYSTEM includes
# so we use O3DEs patched implementation if it is available and fallback to default if not.
if (COMMAND ly_target_include_system_directories)
    ly_target_include_system_directories(TARGET ${TARGET_WITH_NAMESPACE} INTERFACE ${OPENSSL_INCLUDE_DIR})
else()
    target_include_directories(${TARGET_WITH_NAMESPACE} SYSTEM INTERFACE ${OPENSSL_INCLUDE_DIR})
endif()

target_link_libraries(${TARGET_WITH_NAMESPACE} INTERFACE ${OPENSSL_LIBRARY})

# set the library file as the imported location so that things know to link to it:

# ly_add_target_files(TARGETS ${TARGET_WITH_NAMESPACE} FILES ${OPENSSL_SHARE_LIBRARIES_RELEASE})


# if we're not in O3DE, it's also extremely helpful to show a message to logs that indicate that this
# library was successfully picked up, as opposed to the system one.
# A good way to know if you're in O3DE or not is that O3DE sets various cache variables before 
# calling find_package, specifically, LY_VERSION_ENGINE_NAME is always set very early:
if (NOT LY_VERSION_ENGINE_NAME)
    message(STATUS "Using the O3DE version of the openssl library from ${CMAKE_CURRENT_LIST_DIR}")
endif()
