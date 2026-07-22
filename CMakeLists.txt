cmake_minimum_required(VERSION 3.30)

project(ai_for_modern_cpp VERSION 0.1.0 LANGUAGES CXX)

option(AIMCPP_BUILD_TESTS "Build tests" ON)

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

set_property(TARGET ai_modern_cpp_core PROPERTY CXX_SCAN_FOR_MODULES ON)

add_executable(ai-modern-cpp src/main.cpp)

target_link_libraries(ai-modern-cpp PRIVATE ai_modern_cpp_core)
target_compile_features(ai-modern-cpp PRIVATE cxx_std_26)
set_property(TARGET ai-modern-cpp PROPERTY CXX_SCAN_FOR_MODULES ON)

if(AIMCPP_BUILD_TESTS)
    enable_testing()

    add_executable(ai-modern-cpp-tests tests/core_tests.cpp)

    target_link_libraries(ai-modern-cpp-tests PRIVATE ai_modern_cpp_core)
    target_compile_features(ai-modern-cpp-tests PRIVATE cxx_std_26)
    set_property(TARGET ai-modern-cpp-tests PROPERTY CXX_SCAN_FOR_MODULES ON)

    add_test(NAME core_tests COMMAND ai-modern-cpp-tests)

    add_test(
        NAME knowledge_contract
        COMMAND
            ${CMAKE_COMMAND}
            "-DAIMCPP_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
            -P
            "${CMAKE_CURRENT_SOURCE_DIR}/tests/knowledge_contract.cmake"
    )

    set_tests_properties(knowledge_contract PROPERTIES LABELS knowledge)

    add_test(
        NAME project_checks
        COMMAND
            ${CMAKE_COMMAND}
            "-DAIMCPP_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
            "-DAIMCPP_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}"
            -P
            "${CMAKE_CURRENT_SOURCE_DIR}/tests/project_checks.cmake"
    )

    set_tests_properties(project_checks PROPERTIES LABELS knowledge)

    option(
        AIMCPP_VERIFY_QT_BASELINE
        "Run the generated Qt Quick baseline integration fixture when Qt is available"
        ON
    )

    if(AIMCPP_VERIFY_QT_BASELINE)
        find_package(Qt6 6.6 QUIET COMPONENTS Quick Qml QuickControls2)

        if(Qt6_FOUND)
            add_test(
                NAME qt_quick_baseline_integration
                COMMAND
                    ${CMAKE_COMMAND}
                    "-DAIMCPP_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
                    "-DAIMCPP_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}"
                    "-DAIMCPP_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
                    "-DAIMCPP_GENERATOR=${CMAKE_GENERATOR}"
                    "-DAIMCPP_QT6_DIR=${Qt6_DIR}"
                    "-DAIMCPP_CTEST_COMMAND=${CMAKE_CTEST_COMMAND}"
                    -P
                    "${CMAKE_CURRENT_SOURCE_DIR}/tests/qt_quick_baseline_integration.cmake"
            )
            set_tests_properties(
                qt_quick_baseline_integration
                PROPERTIES
                    LABELS "integration;qt"
                    TIMEOUT 180
            )
            message(STATUS
                "AIMCPP_QT_BASELINE=ENABLED (Qt ${Qt6_VERSION})"
            )
        else()
            message(STATUS
                "AIMCPP_QT_BASELINE=NOT VERIFIED (Qt 6.6+ Quick/Qml/QuickControls2 unavailable)"
            )
        endif()
    else()
        message(STATUS "AIMCPP_QT_BASELINE=DISABLED")
    endif()
endif()

message(STATUS "CMAKE_VERSION=${CMAKE_VERSION}")
message(STATUS "CMAKE_GENERATOR=${CMAKE_GENERATOR}")
message(STATUS "CMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}")
message(STATUS "CMAKE_CXX_COMPILER_VERSION=${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "AIMCPP_PROJECT_MODULES=ON")
message(STATUS "AIMCPP_STANDARD_LIBRARY=HEADERS")
