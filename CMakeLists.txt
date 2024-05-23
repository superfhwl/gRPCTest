cmake_minimum_required(VERSION 3.15)
project(MyGrpcProject)

# 包含由 Conan 生成的工具链文件
include(${CMAKE_BINARY_DIR}/../conan/conan_toolchain.cmake)

# 设置项目标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找 protobuf 包
find_package(Protobuf CONFIG REQUIRED)
find_package(gRPC CONFIG REQUIRED)

# # 定义生成 gRPC 文件的宏
# function(grpc_generate_cpp SRCS HDRS)
#     set(_proto_files ${ARGN})
#     set(_generated_files "")

#     foreach(_proto_file ${_proto_files})
#         get_filename_component(_proto_file_abs ${_proto_file} ABSOLUTE)
#         get_filename_component(_proto_path ${_proto_file_abs} PATH)
#         get_filename_component(_proto_name ${_proto_file_abs} NAME_WE)

#         list(APPEND _generated_files "${CMAKE_BINARY_DIR}/generated/${_proto_name}.pb.cc")
#         list(APPEND _generated_files "${CMAKE_BINARY_DIR}/generated/${_proto_name}.pb.h")
#         list(APPEND _generated_files "${CMAKE_BINARY_DIR}/generated/${_proto_name}.grpc.pb.cc")
#         list(APPEND _generated_files "${CMAKE_BINARY_DIR}/generated/${_proto_name}.grpc.pb.h")

#         add_custom_command(
#             OUTPUT "${CMAKE_BINARY_DIR}/generated/${_proto_name}.pb.cc"
#                    "${CMAKE_BINARY_DIR}/generated/${_proto_name}.pb.h"
#                    "${CMAKE_BINARY_DIR}/generated/${_proto_name}.grpc.pb.cc"
#                    "${CMAKE_BINARY_DIR}/generated/${_proto_name}.grpc.pb.h"
#             COMMAND ${Protobuf_PROTOC_EXECUTABLE}
#             ARGS --grpc_out=${CMAKE_BINARY_DIR}/generated
#                  --cpp_out=${CMAKE_BINARY_DIR}/generated
#                  --plugin=protoc-gen-grpc=${gRPC_PLUGIN}
#                  -I ${_proto_path}
#                  ${_proto_file_abs}
#             DEPENDS ${_proto_file_abs}
#             COMMENT "Generating ${_proto_file}"
#             VERBATIM
#         )
#     endforeach()

#     set(${SRCS} ${${SRCS}} ${_generated_files} PARENT_SCOPE)
#     set(${HDRS} ${${HDRS}} ${_generated_files} PARENT_SCOPE)
# endfunction()


# 定义你的 .proto 文件
set(PROTO_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/protos/message.proto")

# protobuf_generate_cpp(PROTO_SRCS PROTO_HDRS ${PROTO_FILE})
# grpc_generate_cpp(GRPC_SRCS GRPC_HDRS ${PROTO_FILE})

# 自动生成 protobuf 和 gRPC 源文件和头文件
add_executable(my_grpc_app)
protobuf_generate(
    TARGET my_grpc_app    
    LANGUAGE cpp
    PROTOS ${PROTO_FILES}
    OUT_VAR PB_OUT_FILES
    # GENERATE_EXTENSIONS .pb.h .pb.cc .grpc.pb.h .grpc.pb.cc
    PLUGIN "protoc-gen-grpc=$<TARGET_FILE:gRPC::grpc_cpp_plugin>"
)

# 添加执行文件
target_sources(my_grpc_app PRIVATE src/grpc_test.cpp ${PB_OUT_FILES})
# add_executable(my_grpc_app src/grpc_test.cpp ${PROTO_SRCS} ${PROTO_HDRS})
# add_executable(my_grpc_app ${PROTO_SRCS} ${PROTO_HDRS} ${GRPC_SRCS} ${GRPC_HDRS} src/grpc_test.cpp)

# 链接 protobuf 和 gRPC 库
target_link_libraries(my_grpc_app gRPC::grpc++ gRPC::grpc++_reflection protobuf::libprotobuf)