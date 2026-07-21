# Approved And Forbidden Patterns

Examples in this file are teaching material. Blocks labeled **Incorrect** must
never be copied into production code.

## Module Declaration And Implementation

**Correct**

```cpp
// project_name.cppm
export module project.name;

import std;

export namespace project::name {

/**
 * @brief Stores a validated project name.
 */
class ProjectName final {
public:
    explicit ProjectName(std::string value);
    [[nodiscard]] auto value() const noexcept -> std::string_view;

private:
    std::string m_value;
};

}
```

```cpp
// project_name.cpp
module project.name;

import std;

namespace project::name {

ProjectName::ProjectName(std::string value)
    : m_value(std::move(value))
{
    if (m_value.empty()) {
        throw std::invalid_argument{"Project name must not be empty."};
    }
}

auto ProjectName::value() const noexcept -> std::string_view
{
    return m_value;
}

}
```

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

**Correct**

```cpp
[[nodiscard]] auto evaluate(std::string_view expressionText) const
    -> std::expected<double, ErrorCode>;
```

**Incorrect**

```cpp
double evaluate_expression(std::string expression_text);
```

The correct form makes the naming, non-owning input, failure contract,
constness, and significant result explicit.

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

## Qt Technology Selection

**Correct**

```cmake
find_package(Qt6 REQUIRED COMPONENTS Quick Qml QuickControls2)
qt_add_qml_module(MyApp URI MyApp QML_FILES qml/Main.qml)
```

**Incorrect for a new UI without an exception**

```cmake
find_package(Qt6 REQUIRED COMPONENTS Widgets)
target_link_libraries(MyApp PRIVATE Qt6::Widgets)
```

The incorrect form violates `GUI-001`, `GUI-002`, and `GUI-012`.

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
