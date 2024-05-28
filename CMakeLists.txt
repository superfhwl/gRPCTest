cmake_minimum_required(VERSION 3.15)
project(MyGrpcProject)

# 设置项目标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Check if vcpkg is being used and disable it
if(DEFINED CMAKE_TOOLCHAIN_FILE AND CMAKE_TOOLCHAIN_FILE MATCHES "vcpkg")
    message(STATUS "Disabling vcpkg toolchain")
    set(CMAKE_TOOLCHAIN_FILE "" CACHE STRING "Force disable vcpkg toolchain" FORCE)
endif()



set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/grpc-packages/absl-windows/")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/grpc-packages/c-ares-windows/")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/grpc-packages/gflags-windows/")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/grpc-packages/grpc-windows/")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/grpc-packages/protobuf-windows/")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/grpc-packages/OpenSSL-windows/")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/grpc-packages/upb-windows/")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/grpc-packages/re2-windows/")
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/grpc-packages/zlib-windows/")

find_package(grpc REQUIRED)
find_package(protobuf REQUIRED)
find_package(gflags REQUIRED)
find_package(absl REQUIRED)
find_package(cares REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(upb REQUIRED)
find_package(re2 REQUIRED)
find_package(zlib REQUIRED)
if (NOT PROTOBUF_FOUND OR NOT GFLAGS_FOUND OR NOT GRPC_FOUND OR NOT ABSL_FOUND OR NOT CARES_FOUND 
    OR NOT OPENSSL_FOUND OR NOT UPB_FOUND OR NOT RE2_FOUND OR NOT ZLIB_FOUND)
    message(FATAL_ERROR "Libs could not be found.")
else()
    message(STATUS "Protobuf version: " ${PROTOBUF_VERSION_STRING} " Incl Dir: " ${PROTOBUF_INCLUDE_DIR} " Libs: " ${PROTOBUF_LIBRARY})
    message(STATUS "gflags version: " ${GFLAGS_VERSION_STRING} " Incl Dir: " ${GFLAGS_INCLUDE_DIR} " Libs: " ${GFLAGS_LIBRARY})    
    message(STATUS "grpc version: " ${GRPC_VERSION_STRING} " Incl Dir: " ${GRPC_INCLUDE_DIR} " Libs: " ${GRPC_LIBRARY})    
    message(STATUS "absl version: " ${ABSL_VERSION_STRING} " Incl Dir: " ${ABSL_INCLUDE_DIR} " Libs: " ${ABSL_LIBRARY})    
    message(STATUS "c-ares version: " ${CARES_VERSION_STRING} " Incl Dir: " ${CARES_INCLUDE_DIR} " Libs: " ${CARES_LIBRARY})    
    message(STATUS "OpenSSL version: " ${OPENSSL_VERSION} " Incl Dir: " ${OPENSSL_INCLUDE_DIR} " Libs: " ${OPENSSL_LIBRARIES})    
    message(STATUS "upb version: " ${UPB_VERSION_STRING} " Incl Dir: " ${UPB_INCLUDE_DIR} " Libs: " ${UPB_LIBRARY})
    message(STATUS "re2 version: " ${RE2_VERSION_STRING} " Incl Dir: " ${RE2_INCLUDE_DIR} " Libs: " ${RE2_LIBRARY})
    message(STATUS "zlib version: " ${ZLIB_VERSION_STRING} " Incl Dir: " ${ZLIB_INCLUDE_DIR} " Libs: " ${ZLIB_LIBRARY})
endif()


# 包含子目录
add_subdirectory(src)


# 链接 protobuf 和 gRPC 库
add_executable(MyGrpcProject main.cpp)
set_target_properties(MyGrpcProject PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    VS_GLOBAL_VcpkgEnabled false
)
target_link_libraries(MyGrpcProject PRIVATE proto_message cpp_greet_service 
3rdParty::protobuf 3rdParty::grpc 3rdParty::gflags 3rdParty::c-ares 3rdParty::absl 3rdParty::OpenSSL 3rdParty::upb 3rdParty::re2 3rdParty::zlib)
    # grpc::gpr grpc::grpc grpc::grpc++ grpc::grpc++_alts protobuf::protobuf)

    