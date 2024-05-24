cmake_minimum_required(VERSION 3.15)
project(MyGrpcProject)

# 包含由 Conan 生成的工具链文件
include(${CMAKE_BINARY_DIR}/../conan/conan_toolchain.cmake)

# 设置项目标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 包含子目录
add_subdirectory(src)

find_package(gRPC REQUIRED)
find_package(protobuf REQUIRED)

find_library(PROTOBUF_LIB NAMES libprotobufd.lib PATHS "${CMAKE_SOURCE_DIR}/3rd_party/libs")
if(NOT PROTOBUF_LIB)
    message(FATAL_ERROR "libprotobufd.lib not found")
endif()

# 链接 protobuf 和 gRPC 库
add_executable(MyGrpcProject main.cpp)

set_target_properties(MyGrpcProject PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

message(STATUS "Protobuf libraries: " ${protobuf_LIBRARIES})
message(STATUS "gRPC libraries: " ${gRPC_LIBRARIES})
message(STATUS "conan libraries: " ${CONAN_LIBS})

link_directories("${CMAKE_SOURCE_DIR}/3rd_party/libs")

target_link_libraries(MyGrpcProject PRIVATE ${PROTOBUF_LIB} protobuf::protobuf grpc::grpc ProtoTest grpc_test)
