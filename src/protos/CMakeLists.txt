find_package(gRPC REQUIRED)
find_package(Protobuf REQUIRED)

set(GRPC_HEADER_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)

# 输出 Protobuf 包含目录
message(STATUS "Protobuf hedaer directories:" ${GRPC_HEADER_DIR})

add_library(ProtoTest message.proto)

set_target_properties(ProtoTest PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

protobuf_generate(TARGET ProtoTest)
protobuf_generate(
    TARGET ProtoTest
    LANGUAGE grpc
    PLUGIN protoc-gen-grpc=$<TARGET_FILE:gRPC::grpc_cpp_plugin>
    PLUGIN_OPTIONS generate_mock_code=true
    GENERATE_EXTENSIONS .grpc.pb.h .grpc.pb.cc
)
target_include_directories(ProtoTest PUBLIC ${Protobuf_INCLUDE_DIRS} ${gRPC_INCLUDE_DIRS} ${absl_INCLUDE_DIRS})
target_link_libraries(ProtoTest)
