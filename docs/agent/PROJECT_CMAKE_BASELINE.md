# Generated Project CMake Baseline

Use this baseline when creating a new module-based C++ project, especially a
Qt Quick application. It intentionally supports project-owned C++ modules while
using standard-library headers. Experimental standard-library modules, metadata,
gates, and mode switches are not part of the generated project.

## Complete Baseline

```cmake
cmake_minimum_required(VERSION 3.30)

project(MyApp VERSION 0.1.0 LANGUAGES CXX)

option(MY_APP_BUILD_GUI "Build the Qt Quick application" ON)
option(MY_APP_BUILD_TESTS "Build tests" ON)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(my_app_core)
target_compile_features(my_app_core PUBLIC cxx_std_26)
target_sources(my_app_core
    PUBLIC
        FILE_SET CXX_MODULES
        FILES
            src/domain/app_domain.cppm
            src/application/app.cppm
    PRIVATE
        src/domain/app_domain.cpp
        src/application/app.cpp
)
set_property(TARGET my_app_core PROPERTY CXX_SCAN_FOR_MODULES ON)

if(MY_APP_BUILD_GUI)
    find_package(Qt6 6.6 REQUIRED COMPONENTS Quick Qml QuickControls2)

    if(QT_KNOWN_POLICY_QTP0004)
        qt_policy(SET QTP0004 NEW)
    endif()

    qt_standard_project_setup(REQUIRES 6.6)

    qt_add_executable(MyApp
        src/bootstrap/main.cpp
    )

    qt_add_qml_module(MyApp
        URI MyApp
        VERSION 1.0
        QML_FILES
            ui/Main.qml
            ui/pages/HomePage.qml
            ui/components/PrimaryActionButton.qml
            ui/theme/Theme.qml
        SOURCES
            src/presentation/app_view_model.cpp
            src/presentation/app_view_model.hpp
    )

    target_include_directories(MyApp
        PRIVATE
            "${CMAKE_CURRENT_SOURCE_DIR}/src/presentation"
    )

    target_link_libraries(MyApp
        PRIVATE
            my_app_core
            Qt6::Quick
            Qt6::Qml
            Qt6::QuickControls2
    )
    target_compile_features(MyApp PRIVATE cxx_std_26)
    set_property(TARGET MyApp PROPERTY CXX_SCAN_FOR_MODULES ON)
endif()

if(MY_APP_BUILD_TESTS)
    enable_testing()

    add_executable(my_app_tests tests/app_tests.cpp)
    target_link_libraries(my_app_tests PRIVATE my_app_core)
    target_compile_features(my_app_tests PRIVATE cxx_std_26)
    set_property(TARGET my_app_tests PROPERTY CXX_SCAN_FOR_MODULES ON)

    add_test(NAME app.behavior COMMAND my_app_tests)
endif()
```

## Required Module Source Shape

Every module unit that needs the standard library uses the global module
fragment:

```cpp
module;

#include <expected>
#include <string>
#include <string_view>

export module my.app.domain;

export namespace my::app::domain {
// Exported declarations.
}
```

Implementation units follow the same ordering with `module my.app.domain;`
instead of `export module`. Executable `.cpp` files include minimal standard
headers normally and then import project modules.

## Why The Presentation Include Directory Is Required

Qt's QML type registrar may generate code shaped like this:

```cpp
#if __has_include(<app_view_model.hpp>)
#include <app_view_model.hpp>
#endif

qmlRegisterTypesAndRevisions<AppViewModel>("MyApp", 1);
```

The generated source lives in the build directory and has lost the original
header path. `target_include_directories(MyApp ... src/presentation)` makes the
basename include resolvable. Without it, metadata generation can succeed while
compilation fails because `AppViewModel` is undeclared.

Do not edit the generated registration source. Do not move the adapter into the
repository root. Keep the responsibility-oriented layout and expose the nested
directory only to the owning QML target.

If the adapter is constructed from QML with `QML_ELEMENT`, do not declare its
QObject class `final`: Qt's generated `QQmlElement<T>` wrapper derives from it.
Use `final` only with a verified registration and ownership strategy in which
QML does not construct the type.

## Qt Policy And Regeneration

The guarded QTP0004 selection must precede `qt_add_qml_module`. It supports QML
files in responsibility-based subdirectories without requiring a newer Qt
version solely for the policy.

When migrating a project that previously used experimental standard-library
modules, clear its build directory or use **Build > Clear CMake Configuration**
in Qt Creator. Generated `.qmltypes` files are expected only after a successful
configure and Generate step.

## Final Delivery Gate

The default options deliberately enable both GUI and tests. Before a generated
project is called complete or packaged as a final download, use a fresh build
directory and run:

```bash
cmake -S . -B build/verify -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DMY_APP_BUILD_GUI=ON \
  -DMY_APP_BUILD_TESTS=ON
cmake --build build/verify --parallel --target all
ctest --test-dir build/verify --output-on-failure --no-tests=error
```

The build evidence must show the Qt executable linking after generated MOC, QML
type-registration, resource, and QML cache sources compile. A generated project
must also provide and run an applicable QML interaction or deterministic GUI
startup smoke test. If Qt is unavailable, the GUI is `NOT VERIFIED` and the
archive is a draft, not a verified final deliverable.
