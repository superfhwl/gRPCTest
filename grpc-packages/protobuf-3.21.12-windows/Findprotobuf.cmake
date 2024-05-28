#
# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
# 
# SPDX-License-Identifier: Apache-2.0 OR MIT
#
#

# the following is like an include guard
set(TARGET_WITH_NAMESPACE "3rdParty::protobuf")
if (TARGET ${TARGET_WITH_NAMESPACE})
    return()
endif()

# note that we mimic the behavior or the Findgrpc.cmake that ships with CMake.
# as such, we declare several variables that other 3rdParty Packages which call
# find_package(protobuf) might be expecting even if O3DE itself does not use them.
# this allows the protobuf package we make to be usable as a drop in replacement
# for other third parties that want to use this protobuf - all you need to do is
# set your CMAKE_MODULE_PATH to the place this package lives and then 
# calls to find_package(protobuf) will result in this one being used.

# variables required from Findjsbim.cmake in CMake source:

if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
    set(PROTOBUF_TOOLS_DIR ${CMAKE_CURRENT_LIST_DIR}/protobuf/tools)

    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(PROTOBUF_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/protobuf/lib/debug)
        set(PROTOBUF_DLL_DST_DIR ${CMAKE_BINARY_DIR}/bin/Debug)               
        set(PROTOBUF_LIBRARY 
            ${PROTOBUF_LIBRARY_DIR}/libprotobufd.lib
            ${PROTOBUF_LIBRARY_DIR}/libprotobuf-lited.lib
            ${PROTOBUF_LIBRARY_DIR}/libprotocd.lib)     
        set(PROTOBUF_SHARE_LIBRARIES
            ${PROTOBUF_LIBRARY_DIR}/libprotobufd.dll
            ${PROTOBUF_LIBRARY_DIR}/libprotobuf-lited.dll
            ${PROTOBUF_LIBRARY_DIR}/libprotocd.dll)                    
    else()
        set(PROTOBUF_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/protobuf/lib/release)
        set(PROTOBUF_DLL_DST_DIR ${CMAKE_BINARY_DIR}/bin/Release)             
        set(PROTOBUF_LIBRARY 
            ${PROTOBUF_LIBRARY_DIR}/libprotobuf.lib
            ${PROTOBUF_LIBRARY_DIR}/libprotobuf-lite.lib
            ${PROTOBUF_LIBRARY_DIR}/libprotoc.lib)
        set(PROTOBUF_SHARE_LIBRARIES
            ${PROTOBUF_LIBRARY_DIR}/libprotobuf.dll
            ${PROTOBUF_LIBRARY_DIR}/libprotobuf-lite.dll
            ${PROTOBUF_LIBRARY_DIR}/libprotoc.dll)       
    endif()
endif()

set(PROTOBUF_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR}/protobuf/include)
set(PROTOBUF_INCLUDE_DIR ${PROTOBUF_INCLUDE_DIRS})

set(PROTOBUF_VERSION_STRING "3.31.12")
set(PROTOBUF_VERSION_MAJOR "3")
set(PROTOBUF_VERSION_MINOR "21")
set(PROTOBUF_VERSION_PATCH "12")
set(PROTOBUF_MAJOR_VERSION "3")
set(PROTOBUF_MINOR_VERSION "21")
set(PROTOBUF_PATCH_VERSION "12")
set(PROTOBUF_FOUND True)

# declare the targets - O3DE has the 3rdParty namespace target, CMake has protobuf::protobuf
add_library(${TARGET_WITH_NAMESPACE} INTERFACE IMPORTED GLOBAL)

# cmake < 3.21 and visual studio < 16.10 don't properly implement SYSTEM includes
# so we use O3DEs patched implementation if it is available and fallback to default if not.
if (COMMAND ly_target_include_system_directories)
    ly_target_include_system_directories(TARGET ${TARGET_WITH_NAMESPACE} INTERFACE ${PROTOBUF_INCLUDE_DIR})
else()
    target_include_directories(${TARGET_WITH_NAMESPACE} SYSTEM INTERFACE ${PROTOBUF_INCLUDE_DIR})
endif()

target_link_libraries(${TARGET_WITH_NAMESPACE} INTERFACE ${PROTOBUF_LIBRARY})

# set the library file as the imported location so that things know to link to it:

if (COMMAND ly_add_target_files)
    ly_add_target_files(TARGETS ${TARGET_WITH_NAMESPACE} FILES ${PROTOBUF_SHARE_LIBRARIES})
else()
    # 定义自定义目标来复制库文件
    add_custom_target(copy_protobuf_libraries ALL
        COMMENT "Copying PROTOBUF shared libraries to ${PROTOBUF_DLL_DST_DIR}"
    )

    # 为每个库文件添加自定义命令
    foreach(LIB ${PROTOBUF_SHARE_LIBRARIES})
        add_custom_command(TARGET copy_protobuf_libraries
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${LIB}
            ${PROTOBUF_DLL_DST_DIR}
            COMMENT "Copying ${LIB} to ${PROTOBUF_DLL_DST_DIR}"
        )
    endforeach()    

    file(MAKE_DIRECTORY ${PROTOBUF_DLL_DST_DIR})
endif()

find_package(grpc REQUIRED)
set(GRPC_LIBRARIES ${GRPC_LIBRARY})
set(PROTOBUF_LIBRARIES ${PROTOBUF_LIBRARY})

set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_TOOLS_DIR}/protoc.exe)
set(GRPC_CPP_PLUGIN_EXECUTABLE ${GRPC_TOOLS_DIR}/grpc_cpp_plugin.exe)
find_library(PROTOBUF_LIBRARIES NAMES protobuf)
find_library(GRPC_LIBRARIES NAMES grpc++ grpc)
find_path(PROTOBUF_INCLUDE_DIR google/protobuf/stubs/common.h)

message(STATUS "PROTOBUF_PROTOC_EXECUTABLE = " ${PROTOBUF_PROTOC_EXECUTABLE})
message(STATUS "GRPC_CPP_PLUGIN_EXECUTABLE = " ${GRPC_CPP_PLUGIN_EXECUTABLE})

if (PROTOBUF_PROTOC_EXECUTABLE AND PROTOBUF_LIBRARIES AND PROTOBUF_INCLUDE_DIR AND GRPC_CPP_PLUGIN_EXECUTABLE AND GRPC_LIBRARIES)
    set(PROTOBUF_FOUND True)
else()
    set(PROTOBUF_FOUND False)
endif()

mark_as_advanced(PROTOBUF_PROTOC_EXECUTABLE PROTOBUF_LIBRARIES PROTOBUF_INCLUDE_DIR GRPC_CPP_PLUGIN_EXECUTABLE GRPC_LIBRARIES)

if (NOT PROTOBUF_FOUND)
    message(FATAL_ERROR "Could not find Protocol Buffers or gRPC")
endif()

function(protobuf_generate)
    cmake_parse_arguments(ARG "" "TARGET;OUT_VAR;APPEND_PATH" "PROTOS;LANGUAGE;PLUGIN;PLUGIN_OPTIONS;GENERATOR" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR "protobuf_generate requires a TARGET argument")
    endif()

    set(_srcs)
    foreach(proto ${ARG_PROTOS})
        get_filename_component(proto_abs ${proto} ABSOLUTE)
        get_filename_component(proto_name ${proto} NAME_WE)

        set(proto_src "${CMAKE_CURRENT_BINARY_DIR}/${proto_name}.pb.cc")
        set(proto_hdr "${CMAKE_CURRENT_BINARY_DIR}/${proto_name}.pb.h")
        list(APPEND _srcs ${proto_src} ${proto_hdr})

        add_custom_command(
            OUTPUT ${proto_src} ${proto_hdr}
            COMMAND ${PROTOBUF_PROTOC_EXECUTABLE}
            ARGS --cpp_out ${CMAKE_CURRENT_BINARY_DIR} -I ${CMAKE_CURRENT_SOURCE_DIR} ${proto_abs}
            DEPENDS ${proto_abs}
            COMMENT "Running C++ protocol buffer compiler on ${proto}"
            VERBATIM
        )

        # Add gRPC generation
        set(grpc_src "${CMAKE_CURRENT_BINARY_DIR}/${proto_name}.grpc.pb.cc")
        set(grpc_hdr "${CMAKE_CURRENT_BINARY_DIR}/${proto_name}.grpc.pb.h")
        list(APPEND _srcs ${grpc_src} ${grpc_hdr})

        add_custom_command(
            OUTPUT ${grpc_src} ${grpc_hdr}
            COMMAND ${PROTOBUF_PROTOC_EXECUTABLE}
            ARGS --grpc_out=${CMAKE_CURRENT_BINARY_DIR} --plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN_EXECUTABLE} -I ${CMAKE_CURRENT_SOURCE_DIR} ${proto_abs}
            DEPENDS ${proto_abs}
            COMMENT "Running gRPC protocol buffer compiler on ${proto}"
            VERBATIM
        )
    endforeach()

    set(${ARG_OUT_VAR} ${_srcs} PARENT_SCOPE)
    target_sources(${ARG_TARGET} PRIVATE ${_srcs})
endfunction()



# if we're not in O3DE, it's also extremely helpful to show a message to logs that indicate that this
# library was successfully picked up, as opposed to the system one.
# A good way to know if you're in O3DE or not is that O3DE sets various cache variables before 
# calling find_package, specifically, LY_VERSION_ENGINE_NAME is always set very early:
if (NOT LY_VERSION_ENGINE_NAME)
    message(STATUS "Using the O3DE version of the protobuf library from ${CMAKE_CURRENT_LIST_DIR}")
endif()
