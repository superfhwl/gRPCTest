cmake_minimum_required(VERSION 3.15)
project(MyGrpcProject)

# 设置项目标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 包含子目录
add_subdirectory(src)

find_package(gRPC REQUIRED)
find_package(Protobuf REQUIRED)

if (NOT Protobuf_VERSION)
    message(FATAL_ERROR "Protobuf could not be found.")
else()
    message(STATUS "Protobuf version: " ${Protobuf_VERSION} " Incl Dir: " ${Protobuf_INCLUDE_DIRS} " Libs: " ${Protobuf_LIBRARIES})
endif()


# 链接 protobuf 和 gRPC 库
add_executable(MyGrpcProject main.cpp)
set_target_properties(MyGrpcProject PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
target_link_libraries(MyGrpcProject PRIVATE proto_message cpp_greet_service
    gRPC::gpr gRPC::grpc gRPC::grpc++ gRPC::grpc++_alts protobuf::libprotoc protobuf::libprotobuf protobuf::libprotobuf-lite)

    