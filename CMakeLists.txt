cmake_minimum_required(VERSION 3.30)

option(AIMCPP_ENABLE_IMPORT_STD "Enable C++26 import std support when available" ON)
option(AIMCPP_BUILD_TESTS "Build tests" ON)

if(AIMCPP_ENABLE_IMPORT_STD)
    if(CMAKE_VERSION VERSION_LESS "3.31.8")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "0e5b6991-d74f-4b3d-a41c-cf096e0b2508"
        )
    elseif(CMAKE_VERSION VERSION_LESS "4.0.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "d0edc3af-4c50-42ea-a356-e2862fe7a444"
        )
    elseif(CMAKE_VERSION VERSION_LESS "4.0.3")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "a9e1cf81-9932-4810-974b-6eccaf14e457"
        )
    elseif(CMAKE_VERSION VERSION_LESS "4.3.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "d0edc3af-4c50-42ea-a356-e2862fe7a444"
        )
    elseif(CMAKE_VERSION VERSION_LESS "4.4.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "451f2fe2-a8a2-47c3-bc32-94786d8fc91b"
        )
    else()
        message(WARNING
            "This CMake version may require a newer CMAKE_EXPERIMENTAL_CXX_IMPORT_STD gate. "
            "Disabling import std integration."
        )
        set(AIMCPP_ENABLE_IMPORT_STD OFF)
    endif()
endif()

if(AIMCPP_ENABLE_IMPORT_STD)
    set(CMAKE_CXX_MODULE_STD ON)
    set(CMAKE_CXX_SCAN_FOR_MODULES ON)

    if(NOT CMAKE_CXX_STDLIB_MODULES_JSON)
        set(_stdlib_module_json_candidates)

        if(APPLE)
            execute_process(
                COMMAND brew --prefix llvm
                OUTPUT_VARIABLE _brew_llvm_prefix
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )

            if(_brew_llvm_prefix)
                list(APPEND _stdlib_module_json_candidates
                    "${_brew_llvm_prefix}/lib/c++/libc++.modules.json"
                )
            endif()

            file(GLOB _homebrew_llvm_json
                "/opt/homebrew/Cellar/llvm/*/lib/c++/libc++.modules.json"
                "/usr/local/Cellar/llvm/*/lib/c++/libc++.modules.json"
            )

            list(APPEND _stdlib_module_json_candidates ${_homebrew_llvm_json})
        endif()

        if(UNIX AND NOT APPLE)
            file(GLOB _linux_stdlib_json
                "/usr/lib/llvm-*/lib/c++/libc++.modules.json"
                "/usr/lib64/llvm-*/lib/c++/libc++.modules.json"
                "/usr/local/lib/llvm-*/lib/c++/libc++.modules.json"
                "/usr/share/libc++/v1/libc++.modules.json"
                "/usr/lib/gcc/*/*/libstdc++.modules.json"
                "/usr/lib64/gcc/*/*/libstdc++.modules.json"
            )

            list(APPEND _stdlib_module_json_candidates ${_linux_stdlib_json})
        endif()

        list(REMOVE_DUPLICATES _stdlib_module_json_candidates)

        foreach(_candidate IN LISTS _stdlib_module_json_candidates)
            if(EXISTS "${_candidate}")
                set(CMAKE_CXX_STDLIB_MODULES_JSON "${_candidate}")
                break()
            endif()
        endforeach()
    endif()
endif()

project(ai_for_modern_cpp VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(ai_modern_cpp_core)

target_compile_features(ai_modern_cpp_core PUBLIC cxx_std_26)

target_sources(ai_modern_cpp_core
    PUBLIC
        FILE_SET CXX_MODULES
        FILES
            src/modern_cpp_agent/modern_cpp_agent.cppm
    PRIVATE
        src/modern_cpp_agent/modern_cpp_agent.cpp
)

if(AIMCPP_ENABLE_IMPORT_STD)
    set_property(TARGET ai_modern_cpp_core PROPERTY CXX_MODULE_STD ON)
    set_property(TARGET ai_modern_cpp_core PROPERTY CXX_SCAN_FOR_MODULES ON)

    if(NOT 26 IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD AND NOT 23 IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD)
        message(FATAL_ERROR
            "This active compiler / standard library / generator combination does not support import std.\n"
            "CMAKE_CXX_COMPILER_IMPORT_STD='${CMAKE_CXX_COMPILER_IMPORT_STD}'\n"
            "Use Ninja and a supported toolchain: Clang 18.1.2+, MSVC 14.36+, or GCC 15+."
        )
    endif()
endif()

add_executable(ai-modern-cpp src/main.cpp)

target_link_libraries(ai-modern-cpp PRIVATE ai_modern_cpp_core)

target_compile_features(ai-modern-cpp PRIVATE cxx_std_26)

if(AIMCPP_ENABLE_IMPORT_STD)
    set_property(TARGET ai-modern-cpp PROPERTY CXX_MODULE_STD ON)
    set_property(TARGET ai-modern-cpp PROPERTY CXX_SCAN_FOR_MODULES ON)
endif()

if(AIMCPP_BUILD_TESTS)
    enable_testing()

    add_executable(ai-modern-cpp-tests tests/core_tests.cpp)

    target_link_libraries(ai-modern-cpp-tests PRIVATE ai_modern_cpp_core)

    target_compile_features(ai-modern-cpp-tests PRIVATE cxx_std_26)

    if(AIMCPP_ENABLE_IMPORT_STD)
        set_property(TARGET ai-modern-cpp-tests PROPERTY CXX_MODULE_STD ON)
        set_property(TARGET ai-modern-cpp-tests PROPERTY CXX_SCAN_FOR_MODULES ON)
    endif()

    add_test(NAME core_tests COMMAND ai-modern-cpp-tests)
endif()

message(STATUS "CMAKE_VERSION=${CMAKE_VERSION}")
message(STATUS "CMAKE_GENERATOR=${CMAKE_GENERATOR}")
message(STATUS "CMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}")
message(STATUS "CMAKE_CXX_COMPILER_VERSION=${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "AIMCPP_ENABLE_IMPORT_STD=${AIMCPP_ENABLE_IMPORT_STD}")
message(STATUS "CMAKE_CXX_COMPILER_IMPORT_STD=${CMAKE_CXX_COMPILER_IMPORT_STD}")
message(STATUS "CMAKE_CXX_STDLIB_MODULES_JSON=${CMAKE_CXX_STDLIB_MODULES_JSON}")
