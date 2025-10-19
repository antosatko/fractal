cmake_minimum_required(VERSION 3.6)
project(fractal)

set(CMAKE_CXX_STANDARD 23)

find_program(ISPC_EXECUTABLE ispc)
if(NOT ISPC_EXECUTABLE)
    message(FATAL_ERROR "ISPC compiler not found")
endif()

set(ISPC_SRC ${CMAKE_CURRENT_SOURCE_DIR}/fractal.ispc)
set(ISPC_OBJ ${CMAKE_CURRENT_BINARY_DIR}/fractal_ispc.o)
set(ISPC_HDR ${CMAKE_CURRENT_SOURCE_DIR}/include/fractal_ispc.h)

add_custom_command(
    OUTPUT ${ISPC_OBJ} ${ISPC_HDR}
    COMMAND ${ISPC_EXECUTABLE} ${ISPC_SRC}
            -o ${ISPC_OBJ} -h ${ISPC_HDR}
            --opt=fast-math
    DEPENDS ${ISPC_SRC}
    COMMENT "Compiling ISPC file without ISPCRT"
)

add_custom_target(ispc_compile DEPENDS ${ISPC_OBJ})

add_executable(fractal main.cpp ${ISPC_OBJ})

target_include_directories(fractal PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

add_dependencies(fractal ispc_compile)
