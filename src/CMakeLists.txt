find_package(gRPC REQUIRED)
find_package(Protobuf REQUIRED)

message(STATUS "Found Protobuf version: ${Protobuf_VERSION}")
message(STATUS "Found gRPC version: ${gRPC_VERSION}")


add_subdirectory(protos)

message(STATUS "PB out directories:" ${GRPC_HEADER_DIR})


# 添加执行文件

add_library(cpp_greet_service cpp_greet_service.cpp)
set_target_properties(cpp_greet_service PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
add_dependencies(cpp_greet_service proto_message)
target_include_directories(cpp_greet_service PUBLIC ${GRPC_HEADER_DIR} ${Protobuf_INCLUDE_DIRS} ${gRPC_INCLUDE_DIRS} ${absl_INCLUDE_DIRS})
target_link_libraries(cpp_greet_service)
