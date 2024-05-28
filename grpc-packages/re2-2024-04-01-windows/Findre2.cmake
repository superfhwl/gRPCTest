#
# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
# 
# SPDX-License-Identifier: Apache-2.0 OR MIT
#
#

# the following is like an include guard
set(TARGET_WITH_NAMESPACE "3rdParty::re2")
if (TARGET ${TARGET_WITH_NAMESPACE})
    return()
endif()

# note that we mimic the behavior or the Findgrpc.cmake that ships with CMake.
# as such, we declare several variables that other 3rdParty Packages which call
# find_package(re2) might be expecting even if O3DE itself does not use them.
# this allows the re2 package we make to be usable as a drop in replacement
# for other third parties that want to use this re2 - all you need to do is
# set your CMAKE_MODULE_PATH to the place this package lives and then 
# calls to find_package(re2) will result in this one being used.

# variables required from Findjsbim.cmake in CMake source:

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(RE2_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/re2/lib/debug)
        set(RE2_DLL_DST_DIR ${CMAKE_BINARY_DIR}/bin/Debug)                
    else()
        set(RE2_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/re2/lib/release)
        set(RE2_DLL_DST_DIR ${CMAKE_BINARY_DIR}/bin/Release)     
    endif()
    set(RE2_LIBRARY 
        ${RE2_LIBRARY_DIR}/re2.lib)    
    set(RE2_SHARE_LIBRARIES
        ${RE2_LIBRARY_DIR}/re2.dll)             
endif()

set(RE2_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR}/re2/include)
set(RE2_INCLUDE_DIR ${RE2_INCLUDE_DIRS})

set(RE2_VERSION_STRING "2024.04.01")
set(RE2_VERSION_MAJOR "2024")
set(RE2_VERSION_MINOR "04")
set(RE2_VERSION_PATCH "01")
set(RE2_MAJOR_VERSION "2024")
set(RE2_MINOR_VERSION "04")
set(RE2_PATCH_VERSION "01")
set(RE2_FOUND True)

# declare the targets - O3DE has the 3rdParty namespace target, CMake has re2::re2
add_library(${TARGET_WITH_NAMESPACE} INTERFACE IMPORTED GLOBAL)

# cmake < 3.21 and visual studio < 16.10 don't properly implement SYSTEM includes
# so we use O3DEs patched implementation if it is available and fallback to default if not.
if (COMMAND ly_target_include_system_directories)
    ly_target_include_system_directories(TARGET ${TARGET_WITH_NAMESPACE} INTERFACE ${RE2_INCLUDE_DIR})
else()
    target_include_directories(${TARGET_WITH_NAMESPACE} SYSTEM INTERFACE ${RE2_INCLUDE_DIR})
endif()

target_link_libraries(${TARGET_WITH_NAMESPACE} INTERFACE ${RE2_LIBRARY})

# set the library file as the imported location so that things know to link to it:

if (COMMAND ly_add_target_files)
    ly_add_target_files(TARGETS ${TARGET_WITH_NAMESPACE} FILES ${RE2_SHARE_LIBRARIES})
else()
    # 定义自定义目标来复制库文件
    add_custom_target(copy_re2_libraries ALL
        COMMENT "Copying RE2 shared libraries to ${RE2_DLL_DST_DIR}"
    )

    # 为每个库文件添加自定义命令
    foreach(LIB ${RE2_SHARE_LIBRARIES})
        add_custom_command(TARGET copy_re2_libraries
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${LIB}
            ${RE2_DLL_DST_DIR}
            COMMENT "Copying ${LIB} to ${RE2_DLL_DST_DIR}"
        )
    endforeach()    

    file(MAKE_DIRECTORY ${RE2_DLL_DST_DIR})
endif()

# if we're not in O3DE, it's also extremely helpful to show a message to logs that indicate that this
# library was successfully picked up, as opposed to the system one.
# A good way to know if you're in O3DE or not is that O3DE sets various cache variables before 
# calling find_package, specifically, LY_VERSION_ENGINE_NAME is always set very early:
if (NOT LY_VERSION_ENGINE_NAME)
    message(STATUS "Using the O3DE version of the re2 library from ${CMAKE_CURRENT_LIST_DIR}")
endif()
