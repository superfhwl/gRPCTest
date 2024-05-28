set(GRPC_HEADER_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)

set(PROTO_FILES message.proto)

add_library(proto_message ${PROTO_FILES})

set_target_properties(proto_message PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    VS_GLOBAL_VcpkgEnabled false    
)

protobuf_generate(
    TARGET proto_message
    PROTOS message.proto
)

# 生成 pb.h pb.cc 文件
target_include_directories(proto_message PUBLIC ${PROTOBUF_INCLUDE_DIRS} ${GRPC_INCLUDE_DIRS} ${ABSL_INCLUDE_DIRS})
target_link_libraries(proto_message)
