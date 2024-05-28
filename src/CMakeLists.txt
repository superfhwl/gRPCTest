add_subdirectory(protos)

message(STATUS "PB out directories:" ${GRPC_HEADER_DIR})


# 添加执行文件

add_library(cpp_greet_service cpp_greet_service.cpp)
set_target_properties(cpp_greet_service PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    VS_GLOBAL_VcpkgEnabled false    
)
add_dependencies(cpp_greet_service proto_message)
target_include_directories(cpp_greet_service PUBLIC ${GRPC_HEADER_DIR} ${PROTOBUF_INCLUDE_DIRS} ${GRPC_INCLUDE_DIRS} ${ABSL_INCLUDE_DIRS})
target_link_libraries(cpp_greet_service)
