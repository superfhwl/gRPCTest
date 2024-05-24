find_package(gRPC REQUIRED)
find_package(Protobuf REQUIRED)

set(GRPC_HEADER_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)

# 输出 Protobuf 包含目录
message(STATUS "Protobuf hedaer directories:" ${GRPC_HEADER_DIR})

set(PROTO_FILES message.proto)

add_library(ProtoTest ${PROTO_FILES})

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

# 使用 protobuf_generate 生成 Python 文件
protobuf_generate(
    TARGET ProtoTest
    LANGUAGE python
    OUT_VAR PYTHON_PROTO_FILES
    GENERATE_EXTENSIONS .py
)

target_include_directories(ProtoTest PUBLIC ${Protobuf_INCLUDE_DIRS} ${gRPC_INCLUDE_DIRS} ${absl_INCLUDE_DIRS})
target_link_libraries(ProtoTest)

# 使用 get_filename_component 获取目录部分
get_filename_component(PROTOC_DIR ${Protobuf_PROTOC_EXECUTABLE} DIRECTORY)


message(STATUS "Proto exec dir: " ${PROTOC_DIR})

# 确定 protoc-gen-grpc_python 插件的路径
find_program(GRPC_PYTHON_PLUGIN protoc-gen-grpc_python)
message(STATUS "GRPC_PYTHON_PLUGIN: " ${GRPC_PYTHON_PLUGIN})

# 手动设置 protoc-gen-grpc_python 插件路径
# 请将 <path_to_protoc_gen_grpc_python> 替换为实际路径
set(GRPC_PYTHON_PLUGIN "<C:/Users/wyang/anaconda3/Lib/site-packages>")


# 使用自定义命令生成 gRPC Python 文件
set(GENERATED_PROTO_DIR ${CMAKE_CURRENT_SOURCE_DIR})
add_custom_command(
    OUTPUT ${GENERATED_PROTO_DIR}/message_pb2_grpc.py
    COMMAND ${Protobuf_PROTOC_EXECUTABLE}
    ARGS --proto_path=${CMAKE_CURRENT_SOURCE_DIR} --grpc_python_out=${GENERATED_PROTO_DIR} --plugin=protoc-gen-grpc=${GRPC_PYTHON_PLUGIN} ${CMAKE_CURRENT_SOURCE_DIR}/message.proto
    DEPENDS ${PROTO_FILES}
)

# 添加生成的 Python 文件到自定义目标
add_custom_target(generate_grpc_python_files ALL DEPENDS ${GENERATED_PROTO_DIR}/message_pb2_grpc.py)

# 添加生成的文件到目标
add_dependencies(ProtoTest generate_grpc_python_files)
