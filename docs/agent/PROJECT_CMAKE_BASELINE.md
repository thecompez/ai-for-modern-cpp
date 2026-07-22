# Generated Project CMake Baseline

Use this baseline when creating a new module-based C++ project, especially a
Qt Quick application. It intentionally supports project-owned C++ modules while
using standard-library headers. Experimental standard-library modules, metadata,
gates, and mode switches are not part of the generated project.

## Complete Baseline

```cmake
cmake_minimum_required(VERSION 3.30)

project(MyApp VERSION 0.1.0 LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(AimcppProjectChecks)

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

    set(my_app_qml_files
        "${CMAKE_CURRENT_SOURCE_DIR}/ui/Main.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/ui/pages/HomePage.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/ui/components/PrimaryActionButton.qml"
        "${CMAKE_CURRENT_SOURCE_DIR}/ui/theme/Theme.qml"
    )

    aimcpp_reject_final_qml_creatable_types(
        SOURCES
            src/presentation/app_view_model.hpp
    )

    if(QT_KNOWN_POLICY_QTP0004)
        qt_policy(SET QTP0004 NEW)
    endif()

    qt_standard_project_setup(REQUIRES 6.6)

    qt_add_executable(MyApp
        src/bootstrap/main.cpp
    )

    target_compile_definitions(MyApp
        PRIVATE
            MY_APP_QT_QUICK_CONTROLS_STYLE=\"Basic\"
    )

    qt_add_qml_module(MyApp
        URI MyApp
        VERSION 1.0
        QML_FILES
            ${my_app_qml_files}
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

    add_custom_target(MyApp_qmllint_strict
        COMMAND Qt6::qmllint
            --bare
            --max-warnings 0
            -I "${CMAKE_CURRENT_BINARY_DIR}"
            ${my_app_qml_files}
        DEPENDS MyApp
        VERBATIM
    )
endif()

if(MY_APP_BUILD_TESTS)
    enable_testing()

    add_executable(my_app_tests tests/app_tests.cpp)
    target_link_libraries(my_app_tests PRIVATE my_app_core)
    target_compile_features(my_app_tests PRIVATE cxx_std_26)
    set_property(TARGET my_app_tests PROPERTY CXX_SCAN_FOR_MODULES ON)

    add_test(NAME app.behavior COMMAND my_app_tests)

    if(MY_APP_BUILD_GUI)
        add_test(NAME app.qml.smoke COMMAND MyApp --smoke-test)
        set_tests_properties(app.qml.smoke PROPERTIES
            ENVIRONMENT
                "QT_QPA_PLATFORM=offscreen;QT_QUICK_CONTROLS_STYLE=Basic;QT_FATAL_WARNINGS=1"
            TIMEOUT 30
        )
    endif()
endif()
```

Copy `cmake/AimcppProjectChecks.cmake` from this repository into the generated
project together with this baseline. The preflight rejects the common
`QML_ELEMENT` plus `final` contradiction during configure with a `GUI-021`
diagnostic. Keep every project-owned QML registration header in its `SOURCES`
list. This early check supplements, and never replaces, the clean full Qt build.

`MyApp_qmllint_strict` uses `--max-warnings 0`; the generated Qt lint target by
itself reports warnings but does not necessarily fail on them. Keep the strict
target in the final gate. When a project needs additional QML import paths, add
them explicitly rather than disabling a lint category.

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

## Required Qt Composition-Root Shape

A custom Controls design uses one explicit, customizable style. Select it before
loading any QML that imports Qt Quick Controls:

```cpp
#include <cstdlib>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QString>

int main(int argc, char* argv[])
{
    QGuiApplication application(argc, argv);

    QQuickStyle::setStyle(
        QStringLiteral(MY_APP_QT_QUICK_CONTROLS_STYLE));

    QQmlApplicationEngine engine;
    // Connect object-creation failure, compose dependencies, then load QML.
    // The --smoke-test path must await explicit readiness and exercise the
    // primary interaction flow before returning success.

    return application.exec();
}
```

Do not replace this with an unspecified platform default. Native macOS and
Windows styles can reject custom `background`, `contentItem`, `indicator`,
delegate, and popup implementations. A native-style application may instead
avoid those replacements and use only the native style's supported surface.

The smoke contract is part of the generated application: `--smoke-test` must
fail on root-component creation failure, reach an explicit application-ready
state, and instantiate the primary path's lazy dialogs, popups, delegates, and
editors. Exiting successfully after a fixed timer is not sufficient. The
`QT_FATAL_WARNINGS=1` test environment makes project-caused Qt/QML warnings
fatal; a narrowly documented platform warning may be handled by an exact test
allowlist, never by disabling warning checks globally.

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
cmake --build build/verify --parallel --target MyApp_qmllint_strict
ctest --test-dir build/verify --output-on-failure --no-tests=error
```

The build evidence must show the Qt executable linking after generated MOC, QML
type-registration, resource, and QML cache sources compile. A generated project
must also provide and run an applicable QML interaction or deterministic GUI
smoke test. Record the effective Qt version and Controls style. The strict lint
target and runtime log must contain zero project warnings, including invalid
properties, unsupported control customization, binding loops, and missing
fonts. If Qt is unavailable, the GUI is `NOT VERIFIED` and the archive is a
draft, not a verified final deliverable.
