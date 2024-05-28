#
# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
# 
# SPDX-License-Identifier: Apache-2.0 OR MIT
#
#

# the following is like an include guard
set(TARGET_WITH_NAMESPACE "3rdParty::absl")
if (TARGET ${TARGET_WITH_NAMESPACE})
    return()
endif()

# note that we mimic the behavior or the Findgrpc.cmake that ships with CMake.
# as such, we declare several variables that other 3rdParty Packages which call
# find_package(absl) might be expecting even if O3DE itself does not use them.
# this allows the absl package we make to be usable as a drop in replacement
# for other third parties that want to use this absl - all you need to do is
# set your CMAKE_MODULE_PATH to the place this package lives and then 
# calls to find_package(absl) will result in this one being used.

# variables required from Findjsbim.cmake in CMake source:

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(ABSL_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/absl/lib/debug)
    else()
        set(ABSL_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/absl/lib/release)
    endif()

    set(ABSL_LIBRARY 
        ${ABSL_LIBRARY_DIR}/abseil_dll.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_commandlineflag.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_commandlineflag_internal.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_config.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_internal.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_marshalling.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_parse.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_private_handle_accessor.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_program_name.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_reflection.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_usage.lib
        ${ABSL_LIBRARY_DIR}/absl_flags_usage_internal.lib
        ${ABSL_LIBRARY_DIR}/absl_log_flags.lib
        ${ABSL_LIBRARY_DIR}/absl_log_internal_fnmatch.lib
        ${ABSL_LIBRARY_DIR}/absl_string_view.lib
        ${ABSL_LIBRARY_DIR}/absl_vlog_config_internal.lib)

endif()

set(ABSL_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR}/absl/include)
set(ABSL_INCLUDE_DIR ${ABSL_INCLUDE_DIRS})

set(ABSL_VERSION_STRING "20240116.2.0")
set(ABSL_VERSION_MAJOR "20240116")
set(ABSL_VERSION_MINOR "2")
set(ABSL_VERSION_PATCH "0")
set(ABSL_MAJOR_VERSION "20240116")
set(ABSL_MINOR_VERSION "2")
set(ABSL_PATCH_VERSION "0")
set(ABSL_FOUND True)

# declare the targets - O3DE has the 3rdParty namespace target, CMake has absl::absl
add_library(${TARGET_WITH_NAMESPACE} INTERFACE IMPORTED GLOBAL)

# cmake < 3.21 and visual studio < 16.10 don't properly implement SYSTEM includes
# so we use O3DEs patched implementation if it is available and fallback to default if not.
if (COMMAND ly_target_include_system_directories)
    ly_target_include_system_directories(TARGET ${TARGET_WITH_NAMESPACE} INTERFACE ${ABSL_INCLUDE_DIR})
else()
    target_include_directories(${TARGET_WITH_NAMESPACE} SYSTEM INTERFACE ${ABSL_INCLUDE_DIR})
endif()

target_link_libraries(${TARGET_WITH_NAMESPACE} INTERFACE ${ABSL_LIBRARY})

# set the library file as the imported location so that things know to link to it:

# ly_add_target_files(TARGETS ${TARGET_WITH_NAMESPACE} FILES ${ABSL_SHARE_LIBRARIES_RELEASE})

# if we're not in O3DE, it's also extremely helpful to show a message to logs that indicate that this
# library was successfully picked up, as opposed to the system one.
# A good way to know if you're in O3DE or not is that O3DE sets various cache variables before 
# calling find_package, specifically, LY_VERSION_ENGINE_NAME is always set very early:
if (NOT LY_VERSION_ENGINE_NAME)
    message(STATUS "Using the O3DE version of the absl library from ${CMAKE_CURRENT_LIST_DIR}")
endif()
