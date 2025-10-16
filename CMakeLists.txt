cmake_minimum_required(VERSION 4.0)
project(fractal)

set(CMAKE_CXX_STANDARD 23)

add_executable(fractal main.cpp)

find_program(ISPC_EXECUTABLE ispc)
if(NOT ISPC_EXECUTABLE)
    message(FATAL_ERROR "ISPC not found")
endif()

set(ISPC_OBJ ${CMAKE_CURRENT_BINARY_DIR}/fractal_ispc.o)
set(INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/include)
set(ISPC_HDR ${INCLUDES}/fractal_ispc.h)

add_custom_command(
        OUTPUT ${ISPC_OBJ}
        COMMAND ${ISPC_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/fractal.ispc -o ${ISPC_OBJ} -h ${ISPC_HDR}
        # It's also good practice to use the full path in DEPENDS
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/fractal.ispc
        COMMENT "Compiling fractal.ispc"
)

add_custom_target(ispc_compile DEPENDS ${ISPC_OBJ})

# Link ISPC object
add_dependencies(fractal ispc_compile)
target_sources(fractal PRIVATE ${ISPC_OBJ})
target_include_directories(fractal PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
