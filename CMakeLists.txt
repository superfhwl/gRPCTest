cmake_minimum_required(VERSION 3.15)
project(MyGrpcProject)

# 包含由 Conan 生成的工具链文件
# include(${CMAKE_BINARY_DIR}/../conan/conan_toolchain.cmake)

# 设置项目标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# # 设置 MSVC 编译器的编译标志
# if(MSVC)
#     # add_compile_definitions(
#     # $<$<CONFIG:Debug>:_ITERATOR_DEBUG_LEVEL=2>
#     # $<$<CONFIG:Release>:_ITERATOR_DEBUG_LEVEL=0>
#     # $<$<CONFIG:RelWithDebInfo>:_ITERATOR_DEBUG_LEVEL=0>
#     # $<$<CONFIG:MinSizeRel>:_ITERATOR_DEBUG_LEVEL=0>
#     # )
#     # 替换 /MD 为 /MDd 专门用于 Debug 模式
#     # string(REPLACE "/MD" "/MDd" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
#     # set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /Zi /Od /RTC1")
#     # set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O2")
#     # set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /Zi /O2")

#     # 直接设置 Debug 和 Release 的编译标志
#     set(CMAKE_CXX_FLAGS_DEBUG "/MDd /Zi /Od /D_ITERATOR_DEBUG_LEVEL=0 ${CMAKE_CXX_FLAGS_DEBUG}")
#     set(CMAKE_CXX_FLAGS_RELEASE "/MD /O2 ${CMAKE_CXX_FLAGS_RELEASE}")
#     set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/MD /Zi /O2 ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
#     set(CMAKE_CXX_FLAGS_MINSIZEREL "/MD /O1 ${CMAKE_CXX_FLAGS_MINSIZEREL}")    
# endif()



# 包含子目录
add_subdirectory(src)

find_package(gRPC REQUIRED)
find_package(Protobuf REQUIRED)

if (NOT Protobuf_VERSION)
    message(FATAL_ERROR "Protobuf could not be found.")
else()
    message(STATUS "Protobuf version: " ${Protobuf_VERSION} " Incl Dir: " ${Protobuf_INCLUDE_DIRS} " Libs: " ${Protobuf_LIBRARIES})
endif()

# find_library(PROTOBUF_LIB NAMES libprotobufd.lib PATHS "${CMAKE_SOURCE_DIR}/3rd_party/libs")
# find_library(GPR_LIB NAMES gpr.lib PATHS "${CMAKE_SOURCE_DIR}/3rd_party/libs")
# find_library(GRPCPP_LIB NAMES grpc++.lib PATHS "${CMAKE_SOURCE_DIR}/3rd_party/libs")
# find_library(GRPCPP_REFLECTION_LIB NAMES grpc++_reflection.lib PATHS "${CMAKE_SOURCE_DIR}/3rd_party/libs")
# find_library(GRPCPP_UNSECURE_LIB NAMES grpc++_unsecure.lib  PATHS "${CMAKE_SOURCE_DIR}/3rd_party/libs")
# find_library(ABSL_BASE_LIB NAMES absl_base.lib  PATHS "${CMAKE_SOURCE_DIR}/3rd_party/libs")
# find_library(ABSL_FLAGS_LIB NAMES absl_flags.lib  PATHS "${CMAKE_SOURCE_DIR}/3rd_party/libs")
# if(NOT PROTOBUF_LIB OR NOT GPR_LIB OR NOT GRPCPP_LIB OR NOT GRPCPP_REFLECTION_LIB OR NOT GRPCPP_UNSECURE_LIB OR NOT ABSL_BASE_LIB OR NOT ABSL_FLAGS_LIB)
#     message(FATAL_ERROR "One or more libraries could not be found.")
# endif()

# 链接 protobuf 和 gRPC 库
add_executable(MyGrpcProject main.cpp)

set_target_properties(MyGrpcProject PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# message(STATUS "Protobuf libraries: " ${protobuf_LIBRARIES})
# message(STATUS "gRPC libraries: " ${gRPC_LIBRARIES})
# message(STATUS "conan libraries: " ${CONAN_LIBS})

# link_directories("${CMAKE_SOURCE_DIR}/3rd_party/libs")

# target_link_libraries(MyGrpcProject PRIVATE ${PROTOBUF_LIB} ${GPR_LIB} ${GRPCPP_LIB} 
#     ${GRPCPP_REFLECTION_LIB} ${GRPCPP_UNSECURE_LIB} ${ABSL_BASE_LIB} ${ABSL_FLAGS_LIB} ${absl_LIBRARIES} ProtoTest grpc_test)
target_link_libraries(MyGrpcProject PRIVATE gRPC::gpr gRPC::grpc gRPC::grpc++ gRPC::grpc++_alts 
                        protobuf::libprotoc protobuf::libprotobuf protobuf::libprotobuf-lite
                        ProtoTest grpc_test)

    