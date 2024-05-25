find_package(gRPC REQUIRED)
find_package(Protobuf REQUIRED)

set(GRPC_HEADER_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)

# 输出 Protobuf 包含目录
message(STATUS "Protobuf hedaer directories:" ${GRPC_HEADER_DIR})

set(PROTO_FILES message.proto)

add_library(proto_message ${PROTO_FILES})

set_target_properties(proto_message PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

protobuf_generate(TARGET proto_message)
protobuf_generate(
    TARGET proto_message
    LANGUAGE grpc
    PLUGIN protoc-gen-grpc=$<TARGET_FILE:gRPC::grpc_cpp_plugin>
    PLUGIN_OPTIONS generate_mock_code=true
    GENERATE_EXTENSIONS .grpc.pb.h .grpc.pb.cc
)

# 生成 pb.h pb.cc 文件
target_include_directories(proto_message PUBLIC ${Protobuf_INCLUDE_DIRS} ${gRPC_INCLUDE_DIRS} ${absl_INCLUDE_DIRS})
target_link_libraries(proto_message)
