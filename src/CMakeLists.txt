find_package(gRPC REQUIRED)
find_package(protobuf REQUIRED)

message(STATUS "Found Protobuf version: ${Protobuf_VERSION}")
message(STATUS "Found gRPC version: ${gRPC_VERSION}")

# protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILE})
# grpc_generate_cpp(GRPC_SRCS GRPC_HDRS ${PROTO_FILE})
add_subdirectory(protos)

message(STATUS "PB out directories:" ${GRPC_HEADER_DIR})


# 添加执行文件

add_library(grpc_test grpc_test.cpp)
set_target_properties(grpc_test PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
target_include_directories(grpc_test PUBLIC ${GRPC_HEADER_DIR} ${protobuf_INCLUDE_DIRS} ${gRPC_INCLUDE_DIRS} ${absl_INCLUDE_DIRS})
target_link_libraries(grpc_test  protobuf::protobuf grpc::grpc )
