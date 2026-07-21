# Approved And Forbidden Patterns

Examples in this file are teaching material. Blocks labeled **Incorrect** must
never be copied into production code.

## Module Declaration And Implementation

**Correct**

```cpp
// project_name.cppm
module;

#if !APP_USE_IMPORT_STD
#include <string>
#include <string_view>
#endif

export module project.name;

#if APP_USE_IMPORT_STD
import std;
#endif

export namespace project::name {

/**
 * @brief Stores a validated project name.
 */
class ProjectName final {
public:
    explicit ProjectName(std::string value);
    [[nodiscard]] std::string_view value() const noexcept;

private:
    std::string m_value;
};

}
```

```cpp
// project_name.cpp
module;

#if !APP_USE_IMPORT_STD
#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>
#endif

module project.name;

#if APP_USE_IMPORT_STD
import std;
#endif

namespace project::name {

ProjectName::ProjectName(std::string value)
    : m_value(std::move(value))
{
    if (m_value.empty()) {
        throw std::invalid_argument{"Project name must not be empty."};
    }
}

std::string_view ProjectName::value() const noexcept
{
    return m_value;
}

}
```

The standard-library path is conditional; the project module is not. Fallback
headers stay in the global module fragment between `module;` and the named
module declaration.

**Incorrect**

```cpp
// project_name.h — forbidden legacy project header
class ProjectName {
public:
    ProjectName(std::string value) : value_(std::move(value)) {}
private:
    std::string value_;
};
```

Violations: `MOD-002`, `MOD-003`, `MOD-006`, and `NAM-005`.

**Incorrect fallback placement**

```cpp
export module project.name;

#include <string>
```

The include is inside the named module purview. This violates `MOD-011` and can
attach textual declarations to the wrong module.

## Recoverable Error

**Correct**

```cpp
[[nodiscard]] auto parseVersion(std::string_view text)
    -> std::expected<Version, ParseError>;
```

**Incorrect**

```cpp
auto parseVersion(std::string_view text, Version& output) -> bool;
```

The incorrect form hides the failure reason and uses an output parameter to
carry a result.

## Enum And Private Member Naming

**Correct**

```cpp
enum class ErrorCode {
    EmptyExpression,
    InvalidToken,
    DivisionByZero
};

class AppState final {
private:
    std::string m_expressionText;
    ErrorCode m_errorCode {ErrorCode::EmptyExpression};
};

case ErrorCode::EmptyExpression:
```

**Incorrect**

```cpp
enum class ErrorCode {
    empty_expression,
    invalid_token
};

class AppState {
private:
    std::string my_member;
    ErrorCode error_code_;
};

case ErrorCode::empty_expression:
```

Violations: `NAM-003`, `NAM-005`, `NAM-006`, `NAM-009`, and `SYN-004`.

## Modern Function Syntax

**Correct for a simple result**

```cpp
void inputDecimalPoint();
[[nodiscard]] bool isReady() const noexcept;
```

**Correct when a longer result benefits from alignment**

```cpp
[[nodiscard]] auto evaluate(std::string_view expressionText) const
    -> std::expected<double, ErrorCode>;
```

**Incorrect for naming and contract design**

```cpp
double evaluate_expression(std::string expression_text);
```

The approved forms choose return syntax based on readability. The API still
makes naming, non-owning input, failure, constness, and significant results
explicit.

## Modern Formatted Console Output

**Correct**

```cpp
std::println("Completed {} operations", operationCount);
std::print("Progress: {}%\r", percentage);
```

**Incorrect for ordinary project output**

```cpp
std::cout << "Completed " << operationCount << " operations\n";
std::cerr << "Operation failed\n";
```

Use `std::format` when the text must become a value instead of being written
immediately. Stream insertion is limited to an explicitly justified API
boundary that accepts only streams.

## Qt Quick Presentation Boundary

**Correct**

```text
QML controls and layout
    → typed C++ view model
        → C++ application module
            → pure C++ domain module
```

```qml
PrimaryActionButton {
    text: qsTr("Continue")
    enabled: !appViewModel.isBusy
    onClicked: appViewModel.requestPrimaryAction()
}
```

**Incorrect**

```qml
Button {
    text: "Continue"
    onClicked: {
        // Validation, persistence, and business decisions belong to C++.
        settingsStore.save(formInput.text)
        applicationState = "ready"
    }
}
```

The incorrect form violates `GUI-003`, `GUI-004`, security boundaries, and the
explicit error model.

## Interaction Surface Selection

**Correct for an unspecified user-facing interactive application**

```text
Qt Quick primary interface
    → C++ presentation adapter
        → shared C++ application and domain modules
    ← optional CLI adapter for automation or headless use
```

**Incorrect**

```text
CLI-only deliverable
    → business behavior embedded in command parsing

No primary graphical interface and no shared application boundary
```

The incorrect form silently chooses a product surface the user did not request
and violates `GUI-015`. If a CLI is useful, `GUI-016` keeps it secondary and
requires both interfaces to share application and domain behavior.

## Qt Technology Selection

**Correct**

```cmake
find_package(Qt6 REQUIRED COMPONENTS Quick Qml QuickControls2)
if(QT_KNOWN_POLICY_QTP0004)
    qt_policy(SET QTP0004 NEW)
endif()
qt_add_qml_module(MyApp URI MyApp QML_FILES ui/Main.qml)
```

**Incorrect for a new UI without an exception**

```cmake
find_package(Qt6 REQUIRED COMPONENTS Widgets)
target_link_libraries(MyApp PRIVATE Qt6::Widgets)
```

The incorrect form violates `GUI-001`, `GUI-002`, and `GUI-012`.

When QML files occupy extra directories, the guarded QTP0004 selection must
precede `qt_add_qml_module`. A missing generated `.qmltypes` file after an
earlier failed Generate step is not evidence that QML registration itself is
the first failure.

## Qt Quick Repository And Experience Shape

**Correct**

```text
src/domain/          Stable product rules
src/application/     Use cases and authoritative state
src/presentation/    Small typed QML-facing adapter
src/adapters/        Platform and third-party boundaries
src/bootstrap/       Composition root
ui/pages/            Screen composition by user task
ui/components/       Reusable roles, not copied decoration
ui/theme/            Design tokens
ui/assets/           Presentation assets
```

```text
Audience → primary task → information hierarchy → interaction states
         → affordances and feedback → visual direction → components
```

**Incorrect**

```text
qml/
  Main.qml           One giant screen and every visual asset

Every screen uses the same rounded cards, gradient, spacing, and dashboard
shell without regard to task, density, feedback, or recovery.
```

The incorrect shape confuses implementation technology with architectural
ownership and violates `ARC-007`, `GUI-017`, and `GUI-018`.

## Resource Ownership

**Correct**

```cpp
class FileHandle final {
public:
    explicit FileHandle(int descriptor) noexcept;
    ~FileHandle();
    FileHandle(const FileHandle&) = delete;
    auto operator=(const FileHandle&) -> FileHandle& = delete;
private:
    int m_descriptor {-1};
};
```

**Incorrect**

```cpp
auto openFile() -> int*;
auto closeFile(int* descriptor) -> void;
```

The incorrect form does not communicate ownership or guarantee cleanup.

## Platform Boundary

**Correct**

```text
project_platform.cppm
project_platform_macos.cpp
project_platform_linux.cpp
```

**Incorrect**

```cpp
auto applicationRule() -> Result
{
#if defined(__APPLE__)
    // Domain behavior A
#else
    // Domain behavior B
#endif
}
```

## CMake Module Registration

**Correct import-std detection order**

```cmake
# Verified version-scoped gate and validated metadata are prepared here.
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "<verified-version-specific-gate>")
set(CMAKE_CXX_STDLIB_MODULES_JSON "<validated-active-toolchain-metadata>")

project(MyApp LANGUAGES CXX)

if(26 IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD)
    set(CMAKE_CXX_MODULE_STD ON)
else()
    set(CMAKE_CXX_MODULE_STD OFF)
endif()
```

**Incorrect import-std detection order**

```cmake
project(MyApp LANGUAGES CXX)
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "<gate-set-too-late>")
set(CMAKE_CXX_MODULE_STD ON)
```

The incorrect form asks CMake to use a capability that was not enabled during
compiler detection. Later metadata or a target property cannot repair that
ordering; recreate the CMake configuration after moving phase-one inputs before
`project()`.

**Correct**

```cmake
target_sources(project_core
    PUBLIC
        FILE_SET CXX_MODULES
        FILES src/project/project.cppm
    PRIVATE
        src/project/project.cpp
)
```

**Incorrect**

```cmake
include_directories(src)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++26")
```

## Verification Report

**Correct**

```text
Configure: PASS
Build: PASS — 20/20
Tests: PASS — 2/2
```

**Incorrect**

```text
It should compile and tests probably pass.
```
