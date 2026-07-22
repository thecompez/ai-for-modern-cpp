cmake_minimum_required(VERSION 3.30)

foreach(requiredVariable IN ITEMS
    AIMCPP_SOURCE_DIR
    AIMCPP_BINARY_DIR
    AIMCPP_CXX_COMPILER
    AIMCPP_GENERATOR
    AIMCPP_QT6_DIR
    AIMCPP_CTEST_COMMAND
)
    if(NOT DEFINED ${requiredVariable} OR "${${requiredVariable}}" STREQUAL "")
        message(FATAL_ERROR "${requiredVariable} is required")
    endif()
endforeach()

set(fixtureSourceDirectory
    "${AIMCPP_SOURCE_DIR}/tests/fixtures/qt_quick_baseline"
)
set(fixtureBuildDirectory
    "${AIMCPP_BINARY_DIR}/qt-quick-baseline-integration"
)

file(REMOVE_RECURSE "${fixtureBuildDirectory}")

function(run_required_step stepName)
    execute_process(
        COMMAND ${ARGN}
        RESULT_VARIABLE stepResult
        OUTPUT_VARIABLE stepOutput
        ERROR_VARIABLE stepError
    )

    if(NOT stepResult EQUAL 0)
        message(FATAL_ERROR
            "${stepName} failed with exit code ${stepResult}:\n"
            "${stepOutput}${stepError}"
        )
    endif()

    message(STATUS "${stepName}: PASS")
endfunction()

run_required_step(
    "Qt baseline configure"
    "${CMAKE_COMMAND}"
    -S "${fixtureSourceDirectory}"
    -B "${fixtureBuildDirectory}"
    -G "${AIMCPP_GENERATOR}"
    -DCMAKE_BUILD_TYPE=Debug
    "-DCMAKE_CXX_COMPILER=${AIMCPP_CXX_COMPILER}"
    "-DQt6_DIR=${AIMCPP_QT6_DIR}"
    -DMY_APP_BUILD_GUI=ON
    -DMY_APP_BUILD_TESTS=ON
)

run_required_step(
    "Qt baseline full build"
    "${CMAKE_COMMAND}"
    --build "${fixtureBuildDirectory}"
    --parallel
    --target all
)

run_required_step(
    "Qt baseline strict QML lint"
    "${CMAKE_COMMAND}"
    --build "${fixtureBuildDirectory}"
    --parallel
    --target MyApp_qmllint_strict
)

run_required_step(
    "Qt baseline CTest"
    "${AIMCPP_CTEST_COMMAND}"
    --test-dir "${fixtureBuildDirectory}"
    --output-on-failure
    --no-tests=error
)

foreach(expectedOutput IN ITEMS
    "qml/MyApp/qmldir"
    "qml/MyApp/MyApp.qmltypes"
)
    if(NOT EXISTS "${fixtureBuildDirectory}/${expectedOutput}")
        message(FATAL_ERROR
            "Qt baseline did not produce ${fixtureBuildDirectory}/${expectedOutput}"
        )
    endif()
endforeach()

set(runtimeCandidates
    "${fixtureBuildDirectory}/bin/MyApp"
    "${fixtureBuildDirectory}/bin/MyApp.exe"
)
set(hasRuntimeOutput OFF)
foreach(runtimeCandidate IN LISTS runtimeCandidates)
    if(EXISTS "${runtimeCandidate}" AND NOT IS_DIRECTORY "${runtimeCandidate}")
        set(hasRuntimeOutput ON)
    endif()
endforeach()

if(NOT hasRuntimeOutput)
    message(FATAL_ERROR
        "Qt baseline runtime output is missing from ${fixtureBuildDirectory}/bin"
    )
endif()

if(EXISTS "${fixtureBuildDirectory}/MyApp")
    message(FATAL_ERROR
        "Qt baseline leaked a MyApp file or directory into the build root"
    )
endif()

message(STATUS
    "Qt baseline outputs verified under bin/MyApp and qml/MyApp"
)
