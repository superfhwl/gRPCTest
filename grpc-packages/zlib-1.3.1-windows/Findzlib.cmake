#
# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
# 
# SPDX-License-Identifier: Apache-2.0 OR MIT
#
#

# the following is like an include guard
set(TARGET_WITH_NAMESPACE "3rdParty::ZLIB")
if (TARGET ${TARGET_WITH_NAMESPACE})
    return()
endif()

# note that we mimic the behavior or the Findgrpc.cmake that ships with CMake.
# as such, we declare several variables that other 3rdParty Packages which call
# find_package(zlib) might be expecting even if O3DE itself does not use them.
# this allows the zlib package we make to be usable as a drop in replacement
# for other third parties that want to use this zlib - all you need to do is
# set your CMAKE_MODULE_PATH to the place this package lives and then 
# calls to find_package(zlib) will result in this one being used.

# variables required from Findjsbim.cmake in CMake source:

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(ZLIB_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/zlib/lib/debug)
        set(ZLIB_DLL_DST_DIR ${CMAKE_BINARY_DIR}/bin/Debug)            
        set(ZLIB_LIBRARY 
            ${ZLIB_LIBRARY_DIR}/zlibd.lib)    
        set(ZLIB_SHARE_LIBRARIES
            ${ZLIB_LIBRARY_DIR}/zlibd1.dll)                  
    else()
        set(ZLIB_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/zlib/lib/release)
        set(ZLIB_DLL_DST_DIR ${CMAKE_BINARY_DIR}/bin/Release)        
        set(ZLIB_LIBRARY 
            ${ZLIB_LIBRARY_DIR}/zlib.lib)       
        set(ZLIB_SHARE_LIBRARIES
            ${ZLIB_LIBRARY_DIR}/zlib1.dll)                     
    endif()
endif()

set(ZLIB_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR}/zlib/include)
set(ZLIB_INCLUDE_DIR ${ZLIB_INCLUDE_DIRS})

set(ZLIB_VERSION_STRING "1.3.1")
set(ZLIB_VERSION_MAJOR "1")
set(ZLIB_VERSION_MINOR "3")
set(ZLIB_VERSION_PATCH "1")
set(ZLIB_MAJOR_VERSION "1")
set(ZLIB_MINOR_VERSION "3")
set(ZLIB_PATCH_VERSION "1")
set(ZLIB_FOUND True)

# declare the targets - O3DE has the 3rdParty namespace target, CMake has zlib::zlib
add_library(${TARGET_WITH_NAMESPACE} INTERFACE IMPORTED GLOBAL)
add_library(ZLIB::ZLIB ALIAS ${TARGET_WITH_NAMESPACE})

# cmake < 3.21 and visual studio < 16.10 don't properly implement SYSTEM includes
# so we use O3DEs patched implementation if it is available and fallback to default if not.
if (COMMAND ly_target_include_system_directories)
    ly_target_include_system_directories(TARGET ${TARGET_WITH_NAMESPACE} INTERFACE ${ZLIB_INCLUDE_DIR})
else()
    target_include_directories(${TARGET_WITH_NAMESPACE} SYSTEM INTERFACE ${ZLIB_INCLUDE_DIR})
endif()

target_link_libraries(${TARGET_WITH_NAMESPACE} INTERFACE ${ZLIB_LIBRARY})

# set the library file as the imported location so that things know to link to it:
set_target_properties(${TARGET_WITH_NAMESPACE} PROPERTIES IMPORTED_LOCATION "${ZLIB_LIBRARY}")

if (COMMAND ly_add_target_files)
    ly_add_target_files(TARGETS ${TARGET_WITH_NAMESPACE} FILES ${ZLIB_SHARE_LIBRARIES})
else()
    # 定义自定义目标来复制库文件
    add_custom_target(copy_zlib_libraries ALL
        COMMENT "Copying ZLIB shared libraries to ${ZLIB_DLL_DST_DIR}"
    )

    # 为每个库文件添加自定义命令
    foreach(LIB ${ZLIB_SHARE_LIBRARIES})
        add_custom_command(TARGET copy_zlib_libraries
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${LIB}
            ${ZLIB_DLL_DST_DIR}
            COMMENT "Copying ${LIB} to ${ZLIB_DLL_DST_DIR}"
        )
    endforeach()    

    file(MAKE_DIRECTORY ${ZLIB_DLL_DST_DIR})
endif()

# if we're not in O3DE, it's also extremely helpful to show a message to logs that indicate that this
# library was successfully picked up, as opposed to the system one.
# A good way to know if you're in O3DE or not is that O3DE sets various cache variables before 
# calling find_package, specifically, LY_VERSION_ENGINE_NAME is always set very early:
if (NOT LY_VERSION_ENGINE_NAME)
    message(STATUS "Using the O3DE version of the zlib library from ${CMAKE_CURRENT_LIST_DIR}")
endif()
