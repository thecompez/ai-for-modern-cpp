cmake_minimum_required(VERSION 3.30)

option(AIMCPP_BUILD_TESTS "Build tests" ON)

set(AIMCPP_STDLIB_MODE "AUTO" CACHE STRING
    "Standard library integration: AUTO, IMPORT_STD, or HEADERS"
)
set_property(CACHE AIMCPP_STDLIB_MODE PROPERTY STRINGS AUTO IMPORT_STD HEADERS)
string(TOUPPER "${AIMCPP_STDLIB_MODE}" AIMCPP_STDLIB_MODE)

if(NOT AIMCPP_STDLIB_MODE STREQUAL "AUTO"
    AND NOT AIMCPP_STDLIB_MODE STREQUAL "IMPORT_STD"
    AND NOT AIMCPP_STDLIB_MODE STREQUAL "HEADERS"
)
    message(FATAL_ERROR
        "AIMCPP_STDLIB_MODE must be AUTO, IMPORT_STD, or HEADERS. "
        "Observed value: '${AIMCPP_STDLIB_MODE}'"
    )
endif()

set(_aimcpp_import_std_probe_enabled OFF)
set(_aimcpp_import_std_probe_reason "")

if(NOT AIMCPP_STDLIB_MODE STREQUAL "HEADERS")
    if(CMAKE_VERSION VERSION_LESS "3.31.8")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "0e5b6991-d74f-4b3d-a41c-cf096e0b2508"
        )
        set(_aimcpp_import_std_probe_enabled ON)
    elseif(CMAKE_VERSION VERSION_LESS "4.0.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "d0edc3af-4c50-42ea-a356-e2862fe7a444"
        )
        set(_aimcpp_import_std_probe_enabled ON)
    elseif(CMAKE_VERSION VERSION_LESS "4.0.3")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "a9e1cf81-9932-4810-974b-6eccaf14e457"
        )
        set(_aimcpp_import_std_probe_enabled ON)
    elseif(CMAKE_VERSION VERSION_LESS "4.3.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "d0edc3af-4c50-42ea-a356-e2862fe7a444"
        )
        set(_aimcpp_import_std_probe_enabled ON)
    elseif(CMAKE_VERSION VERSION_LESS "4.4.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "451f2fe2-a8a2-47c3-bc32-94786d8fc91b"
        )
        set(_aimcpp_import_std_probe_enabled ON)
    elseif(CMAKE_VERSION VERSION_LESS "4.5.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "f35a9ac6-8463-4d38-8eec-5d6008153e7d"
        )
        set(_aimcpp_import_std_probe_enabled ON)
    else()
        set(_aimcpp_import_std_probe_reason
            "CMake ${CMAKE_VERSION} requires an unverified import-std experimental gate."
        )
    endif()
endif()

set(CMAKE_CXX_SCAN_FOR_MODULES ON)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/AimcppImportStd.cmake")

if(_aimcpp_import_std_probe_enabled)
    aimcpp_prepare_gnu_import_std(
        _aimcpp_gnu_stdlib_modules_json
        _aimcpp_gnu_import_std_failure
    )

    if(_aimcpp_gnu_import_std_failure)
        set(_aimcpp_import_std_probe_reason "${_aimcpp_gnu_import_std_failure}")
        set(_aimcpp_import_std_probe_enabled OFF)
        unset(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD)
        unset(CMAKE_CXX_STDLIB_MODULES_JSON)
        unset(CMAKE_CXX_STDLIB_MODULES_JSON CACHE)
    endif()
endif()

if(_aimcpp_gnu_stdlib_modules_json)
    set(CMAKE_CXX_STDLIB_MODULES_JSON "${_aimcpp_gnu_stdlib_modules_json}")
endif()

if(_aimcpp_import_std_probe_enabled AND APPLE AND CMAKE_CXX_COMPILER)
    execute_process(
        COMMAND brew --prefix llvm
        OUTPUT_VARIABLE _brew_llvm_prefix
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    if(_brew_llvm_prefix)
        file(REAL_PATH "${_brew_llvm_prefix}" _brew_llvm_real_prefix)
        file(REAL_PATH "${CMAKE_CXX_COMPILER}" _active_cxx_compiler)

        string(FIND
            "${_active_cxx_compiler}"
            "${_brew_llvm_real_prefix}/"
            _brew_llvm_compiler_position
        )

        if(_brew_llvm_compiler_position EQUAL 0
            AND EXISTS "${_brew_llvm_real_prefix}/lib/c++/libc++.modules.json"
        )
            set(_aimcpp_homebrew_stdlib_modules_json
                "${_brew_llvm_real_prefix}/lib/c++/libc++.modules.json"
            )

            if(NOT EXISTS "${CMAKE_CXX_STDLIB_MODULES_JSON}")
                set(CMAKE_CXX_STDLIB_MODULES_JSON
                    "${_brew_llvm_real_prefix}/lib/c++/libc++.modules.json"
                )
            endif()
        endif()
    endif()
endif()

project(ai_for_modern_cpp VERSION 0.1.0 LANGUAGES CXX)

if(_aimcpp_homebrew_stdlib_modules_json
    AND NOT EXISTS "${CMAKE_CXX_STDLIB_MODULES_JSON}"
)
    set(CMAKE_CXX_STDLIB_MODULES_JSON
        "${_aimcpp_homebrew_stdlib_modules_json}"
    )
endif()

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(AIMCPP_USE_IMPORT_STD OFF)

if(_aimcpp_import_std_probe_enabled
    AND NOT _aimcpp_import_std_probe_reason
    AND (26 IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD
        OR 23 IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD)
)
    set(AIMCPP_USE_IMPORT_STD ON)
endif()

if(AIMCPP_STDLIB_MODE STREQUAL "IMPORT_STD" AND NOT AIMCPP_USE_IMPORT_STD)
    message(FATAL_ERROR
        "AIMCPP_STDLIB_MODE=IMPORT_STD requires an effective import-std toolchain.\n"
        "CMAKE_CXX_COMPILER_IMPORT_STD='${CMAKE_CXX_COMPILER_IMPORT_STD}'\n"
        "CMAKE_CXX_COMPILER_IMPORT_STD_ERROR_MESSAGE='${CMAKE_CXX_COMPILER_IMPORT_STD_ERROR_MESSAGE}'\n"
        "Probe detail: ${_aimcpp_import_std_probe_reason}\n"
        "Use AIMCPP_STDLIB_MODE=AUTO or HEADERS to keep project modules while "
        "using standard-library headers in global module fragments."
    )
endif()

if(AIMCPP_USE_IMPORT_STD)
    set(AIMCPP_STDLIB_INTEGRATION "IMPORT_STD")
else()
    set(AIMCPP_STDLIB_INTEGRATION "HEADERS")
endif()

set(CMAKE_CXX_MODULE_STD ${AIMCPP_USE_IMPORT_STD})

add_library(ai_modern_cpp_core)

target_compile_features(ai_modern_cpp_core PUBLIC cxx_std_26)

if(AIMCPP_USE_IMPORT_STD)
    target_compile_definitions(ai_modern_cpp_core PUBLIC AIMCPP_USE_IMPORT_STD=1)
else()
    target_compile_definitions(ai_modern_cpp_core PUBLIC AIMCPP_USE_IMPORT_STD=0)
endif()

target_sources(ai_modern_cpp_core
    PUBLIC
        FILE_SET CXX_MODULES
        FILES
            src/modern_cpp_agent/modern_cpp_agent.cppm
    PRIVATE
        src/modern_cpp_agent/modern_cpp_agent.cpp
)

set_property(TARGET ai_modern_cpp_core PROPERTY CXX_MODULE_STD ${AIMCPP_USE_IMPORT_STD})
set_property(TARGET ai_modern_cpp_core PROPERTY CXX_SCAN_FOR_MODULES ON)

add_executable(ai-modern-cpp src/main.cpp)

target_link_libraries(ai-modern-cpp PRIVATE ai_modern_cpp_core)

target_compile_features(ai-modern-cpp PRIVATE cxx_std_26)

set_property(TARGET ai-modern-cpp PROPERTY CXX_MODULE_STD ${AIMCPP_USE_IMPORT_STD})
set_property(TARGET ai-modern-cpp PROPERTY CXX_SCAN_FOR_MODULES ON)

if(AIMCPP_BUILD_TESTS)
    enable_testing()

    add_executable(ai-modern-cpp-tests tests/core_tests.cpp)

    target_link_libraries(ai-modern-cpp-tests PRIVATE ai_modern_cpp_core)

    target_compile_features(ai-modern-cpp-tests PRIVATE cxx_std_26)

    set_property(TARGET ai-modern-cpp-tests PROPERTY CXX_MODULE_STD ${AIMCPP_USE_IMPORT_STD})
    set_property(TARGET ai-modern-cpp-tests PROPERTY CXX_SCAN_FOR_MODULES ON)

    add_test(NAME core_tests COMMAND ai-modern-cpp-tests)

    add_test(
        NAME import_std_metadata
        COMMAND
            ${CMAKE_COMMAND}
            "-DAIMCPP_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
            "-DAIMCPP_TEST_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}/import-std-metadata-test"
            -P
            "${CMAKE_CURRENT_SOURCE_DIR}/tests/import_std_metadata.cmake"
    )

    set_tests_properties(import_std_metadata PROPERTIES LABELS toolchain)

    add_test(
        NAME knowledge_contract
        COMMAND
            ${CMAKE_COMMAND}
            "-DAIMCPP_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
            -P
            "${CMAKE_CURRENT_SOURCE_DIR}/tests/knowledge_contract.cmake"
    )

    set_tests_properties(knowledge_contract PROPERTIES LABELS knowledge)
endif()

message(STATUS "CMAKE_VERSION=${CMAKE_VERSION}")
message(STATUS "CMAKE_GENERATOR=${CMAKE_GENERATOR}")
message(STATUS "CMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}")
message(STATUS "CMAKE_CXX_COMPILER_VERSION=${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "AIMCPP_STDLIB_MODE=${AIMCPP_STDLIB_MODE}")
message(STATUS "AIMCPP_STDLIB_INTEGRATION=${AIMCPP_STDLIB_INTEGRATION}")
message(STATUS "AIMCPP_USE_IMPORT_STD=${AIMCPP_USE_IMPORT_STD}")
message(STATUS "AIMCPP_IMPORT_STD_PROBE_DETAIL=${_aimcpp_import_std_probe_reason}")
message(STATUS "CMAKE_CXX_COMPILER_IMPORT_STD=${CMAKE_CXX_COMPILER_IMPORT_STD}")
message(STATUS "CMAKE_CXX_STDLIB_MODULES_JSON=${CMAKE_CXX_STDLIB_MODULES_JSON}")
