# Generated Project CMake Baseline

Use this baseline when creating a new module-based C++ project, especially a
Qt Quick application. It combines the two ordering constraints that generated
projects must not split or reorder:

1. Prepare experimental `import std` detection inputs before C++ is enabled.
2. Consume the detected capability and register Qt/QML targets afterward.

The repository root `CMakeLists.txt` is the executable proof for the
standard-library portion. Copy `cmake/AimcppImportStd.cmake` into the generated
project's `cmake/` directory; it contains the validated GNU metadata preparation
used by that proof.

## Phase One: Before `project()`

```cmake
cmake_minimum_required(VERSION 3.31)

set(APP_STDLIB_MODE "AUTO" CACHE STRING
    "Standard-library mode: AUTO, IMPORT_STD, or HEADERS"
)
set_property(CACHE APP_STDLIB_MODE PROPERTY STRINGS AUTO IMPORT_STD HEADERS)
string(TOUPPER "${APP_STDLIB_MODE}" APP_STDLIB_MODE)

if(NOT APP_STDLIB_MODE STREQUAL "AUTO"
    AND NOT APP_STDLIB_MODE STREQUAL "IMPORT_STD"
    AND NOT APP_STDLIB_MODE STREQUAL "HEADERS"
)
    message(FATAL_ERROR
        "APP_STDLIB_MODE must be AUTO, IMPORT_STD, or HEADERS. "
        "Observed value: '${APP_STDLIB_MODE}'"
    )
endif()

set(APP_IMPORT_STD_PROBE_ENABLED OFF)
set(APP_IMPORT_STD_PROBE_REASON "")

if(NOT APP_STDLIB_MODE STREQUAL "HEADERS")
    if(CMAKE_VERSION VERSION_LESS "3.31.8")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "0e5b6991-d74f-4b3d-a41c-cf096e0b2508"
        )
        set(APP_IMPORT_STD_PROBE_ENABLED ON)
    elseif(CMAKE_VERSION VERSION_LESS "4.0.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "d0edc3af-4c50-42ea-a356-e2862fe7a444"
        )
        set(APP_IMPORT_STD_PROBE_ENABLED ON)
    elseif(CMAKE_VERSION VERSION_LESS "4.0.3")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "a9e1cf81-9932-4810-974b-6eccaf14e457"
        )
        set(APP_IMPORT_STD_PROBE_ENABLED ON)
    elseif(CMAKE_VERSION VERSION_LESS "4.3.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "d0edc3af-4c50-42ea-a356-e2862fe7a444"
        )
        set(APP_IMPORT_STD_PROBE_ENABLED ON)
    elseif(CMAKE_VERSION VERSION_LESS "4.4.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "451f2fe2-a8a2-47c3-bc32-94786d8fc91b"
        )
        set(APP_IMPORT_STD_PROBE_ENABLED ON)
    elseif(CMAKE_VERSION VERSION_LESS "4.5.0")
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
            "f35a9ac6-8463-4d38-8eec-5d6008153e7d"
        )
        set(APP_IMPORT_STD_PROBE_ENABLED ON)
    else()
        set(APP_IMPORT_STD_PROBE_REASON
            "CMake ${CMAKE_VERSION} has no verified import-std gate."
        )
    endif()
endif()

set(CMAKE_CXX_SCAN_FOR_MODULES ON)

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/AimcppImportStd.cmake")

if(APP_IMPORT_STD_PROBE_ENABLED)
    aimcpp_prepare_gnu_import_std(
        APP_GNU_STDLIB_MODULES_JSON
        APP_GNU_IMPORT_STD_FAILURE
    )

    if(APP_GNU_IMPORT_STD_FAILURE)
        set(APP_IMPORT_STD_PROBE_REASON "${APP_GNU_IMPORT_STD_FAILURE}")
        set(APP_IMPORT_STD_PROBE_ENABLED OFF)
        unset(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD)
        unset(CMAKE_CXX_STDLIB_MODULES_JSON)
        unset(CMAKE_CXX_STDLIB_MODULES_JSON CACHE)
    elseif(APP_GNU_STDLIB_MODULES_JSON)
        set(CMAKE_CXX_STDLIB_MODULES_JSON
            "${APP_GNU_STDLIB_MODULES_JSON}"
        )
    endif()
endif()

# Associate Homebrew libc++ metadata only with the active Homebrew compiler.
if(APP_IMPORT_STD_PROBE_ENABLED AND APPLE AND CMAKE_CXX_COMPILER)
    execute_process(
        COMMAND brew --prefix llvm
        OUTPUT_VARIABLE APP_HOMEBREW_LLVM_PREFIX
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET
    )

    if(APP_HOMEBREW_LLVM_PREFIX)
        file(REAL_PATH
            "${APP_HOMEBREW_LLVM_PREFIX}"
            APP_HOMEBREW_LLVM_REAL_PREFIX
        )
        file(REAL_PATH "${CMAKE_CXX_COMPILER}" APP_ACTIVE_CXX_COMPILER)
        string(FIND
            "${APP_ACTIVE_CXX_COMPILER}"
            "${APP_HOMEBREW_LLVM_REAL_PREFIX}/"
            APP_HOMEBREW_COMPILER_POSITION
        )

        if(APP_HOMEBREW_COMPILER_POSITION EQUAL 0
            AND EXISTS
                "${APP_HOMEBREW_LLVM_REAL_PREFIX}/lib/c++/libc++.modules.json"
        )
            set(CMAKE_CXX_STDLIB_MODULES_JSON
                "${APP_HOMEBREW_LLVM_REAL_PREFIX}/lib/c++/libc++.modules.json"
            )
        endif()
    endif()
endif()

project(MyApp VERSION 0.1.0 LANGUAGES CXX)
```

Do not move `CMAKE_EXPERIMENTAL_CXX_IMPORT_STD`, validated metadata, or module
scanning below `project()`. CMake discovers the capability while enabling C++.

## Phase Two: After `project()`

```cmake
set(APP_USE_IMPORT_STD OFF)

if(APP_IMPORT_STD_PROBE_ENABLED
    AND (26 IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD
        OR 23 IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD)
)
    set(APP_USE_IMPORT_STD ON)
endif()

if(APP_STDLIB_MODE STREQUAL "IMPORT_STD" AND NOT APP_USE_IMPORT_STD)
    message(FATAL_ERROR
        "IMPORT_STD was requested, but the effective toolchain does not "
        "advertise support. "
        "CMAKE_CXX_COMPILER_IMPORT_STD='${CMAKE_CXX_COMPILER_IMPORT_STD}'. "
        "Probe detail: ${APP_IMPORT_STD_PROBE_REASON}"
    )
endif()

set(CMAKE_CXX_MODULE_STD ${APP_USE_IMPORT_STD})

add_library(app_core)
target_compile_features(app_core PUBLIC cxx_std_26)
target_compile_definitions(
    app_core
    PUBLIC APP_USE_IMPORT_STD=$<BOOL:${APP_USE_IMPORT_STD}>
)
target_sources(
    app_core
    PUBLIC
        FILE_SET CXX_MODULES
        FILES src/application/app.cppm
    PRIVATE
        src/application/app.cpp
)
set_property(TARGET app_core PROPERTY CXX_MODULE_STD ${APP_USE_IMPORT_STD})
set_property(TARGET app_core PROPERTY CXX_SCAN_FOR_MODULES ON)
```

`CMAKE_CXX_COMPILER_IMPORT_STD` is read-only evidence produced by CMake. Do not
populate it manually from a compiler version or the existence of a JSON file.

## Qt Quick Registration

```cmake
find_package(Qt6 6.6 REQUIRED COMPONENTS Quick Qml QuickControls2)

if(QT_KNOWN_POLICY_QTP0004)
    qt_policy(SET QTP0004 NEW)
endif()

qt_standard_project_setup(REQUIRES 6.6)

qt_add_executable(MyApp
    src/bootstrap/main.cpp
    src/presentation/app_view_model.cpp
    src/presentation/app_view_model.hpp
)

qt_add_qml_module(MyApp
    URI MyApp
    VERSION 1.0
    QML_FILES
        ui/Main.qml
        ui/pages/HomePage.qml
        ui/components/PrimaryActionButton.qml
        ui/theme/Theme.qml
)

target_link_libraries(MyApp
    PRIVATE
        app_core
        Qt6::Quick
        Qt6::Qml
        Qt6::QuickControls2
)
```

The guarded QTP0004 selection must precede `qt_add_qml_module`. It supports
QML files in responsibility-based subdirectories without pretending the
project requires a newer Qt release than its declared minimum.

## Regeneration Rule

After changing anything in phase one, recreate the CMake configuration. In Qt
Creator, use **Build > Clear CMake Configuration**, then configure again. A
missing generated `.qmltypes` file after a failed Generate step is a cascading
symptom; diagnose the first CMake error first.
