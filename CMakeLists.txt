cmake_minimum_required(VERSION 3.10)
project(Latex_to_Markdown_Converter)

# Enable C++11 standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Source files (note: lex.yy.cpp and parser.tab.cpp are generated)
set(SOURCE_FILES
    main.cpp
    ast.cpp
    converter.cpp
)

# Include directories
include_directories(${CMAKE_SOURCE_DIR})  
include_directories(${CMAKE_BINARY_DIR})  

# Bison (parser)
add_custom_command(
    OUTPUT parser.tab.cpp parser.tab.h
    COMMAND bison -d -v ${CMAKE_SOURCE_DIR}/parser.y -o parser.tab.cpp
    DEPENDS ${CMAKE_SOURCE_DIR}/parser.y
    COMMENT "Running bison on parser.y"
)

# Flex (lex)
add_custom_command(
    OUTPUT lex.yy.cpp
    COMMAND flex -o lex.yy.cpp ${CMAKE_SOURCE_DIR}/lex.l
    DEPENDS ${CMAKE_SOURCE_DIR}/lex.l parser.tab.h
    COMMENT "Running flex on lex.l"
)

# Add the generated files to the list of sources
list(APPEND SOURCE_FILES lex.yy.cpp parser.tab.cpp)

# Executable
add_executable(compiler ${SOURCE_FILES})

# Google Test setup

# Specify the path to Google Test installed via Homebrew
set(GTEST_ROOT /opt/homebrew/Cellar/googletest/1.15.2)
find_package(GTest REQUIRED PATHS ${GTEST_ROOT} NO_DEFAULT_PATH)

# Enable testing
enable_testing()

# Include the GTest library directories
include_directories(${GTEST_INCLUDE_DIRS})

# Unit Tests
add_executable(runUnitTests test.cpp ast.cpp converter.cpp) 

# Link GTest and your project files to the test executable
target_link_libraries(runUnitTests GTest::gtest GTest::gtest_main)

# Clean up generated files
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "parser.tab.cpp;parser.tab.h;lex.yy.cpp;ast.txt")

add_custom_target(clean_md_files
    COMMAND find ${CMAKE_SOURCE_DIR} -type f -name "*.md" ! -name "readme.md" -exec rm -f {} +
    COMMENT "Cleaning up markdown files"
)

add_custom_target(clean_all
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target clean
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target clean_md_files
    COMMENT "Cleaning up generated files and markdown files"
)
