# cmake_minimum_required(VERSION 3.10)

# project(program)

# include_directories(inc)

# add_executable(main
#     main.cpp
#     src/mmath.cpp
# )

cmake_minimum_required(VERSION 3.20)

project(program)

add_executable(main
    main.cpp
    src/mmath.cpp    
)

target_include_directories(main
    PRIVATE
    inc
)

target_compile_definitions(main
    PRIVATE
    DEBUG
)

target_compile_options(main
    PRIVATE
    -Wall
    -O2
)
