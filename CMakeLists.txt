cmake_minimum_required(VERSION 3.10)

project(demo_project LANGUAGES C CXX)

add_compile_options(-g)

set(CMAKE_BUILD_TYPE Debug)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Debug build")
else()
    message(STATUS "Release build")
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)

include_directories(module)

add_library(calc_shared SHARED module/calc.c)
set_target_properties(calc_shared PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin
)

add_executable(main main.cpp)
target_link_libraries(main calc_shared)
 