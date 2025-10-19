cmake_minimum_required(VERSION 4.0)
project(fractal)

set(CMAKE_CXX_STANDARD 23)

find_package(ISPCRT REQUIRED)

add_executable(fractal main.cpp)

target_include_directories(fractal PRIVATE ${ISPCRT_INCLUDE_DIRS})

find_program(ISPC_EXECUTABLE ispc)
if(NOT ISPC_EXECUTABLE)
    message(FATAL_ERROR "ISPC not found")
endif()

set(ISPC_OBJ ${CMAKE_CURRENT_BINARY_DIR}/fractal_ispc.o)
set(INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(ISPC_HDR ${INCLUDES}/fractal_ispc.h)

add_custom_command(
        OUTPUT ${ISPC_OBJ}
        COMMAND ${ISPC_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/fractal-mt.ispc -o ${ISPC_OBJ} -h ${ISPC_HDR} --opt=fast-math
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/fractal-mt.ispc
        COMMENT "Compiling fractal.ispc"
)

add_custom_target(ispc_compile DEPENDS ${ISPC_OBJ})

add_dependencies(fractal ispc_compile)
target_sources(fractal PRIVATE ${ISPC_OBJ})
target_include_directories(fractal PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
