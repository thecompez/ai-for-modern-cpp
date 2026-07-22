# Approved And Forbidden Patterns

Examples in this file are teaching material. Blocks labeled **Incorrect** must
never be copied into production code.

## Module Declaration And Implementation

**Correct**

```cpp
// project_name.cppm
module;

#include <string>
#include <string_view>

export module project.name;

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

#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>

module project.name;

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

Standard headers stay in the global module fragment between `module;` and the
named module declaration. The project module remains the public boundary.

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

**Incorrect standard-header placement**

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
target_include_directories(MyApp PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/presentation")
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
the first failure. A nested `QML_ELEMENT` header must also be reachable through
the owning target's include directories so generated registration code can
include it by basename.

## Qt Quick Controls Style Selection

**Correct for product-owned custom controls**

```cpp
QQuickStyle::setStyle(QStringLiteral("Basic"));
QQmlApplicationEngine engine;
```

```qml
Button {
    contentItem: Text { text: control.text }
    background: Rectangle { radius: theme.controlRadius }
}
```

**Incorrect**

```qml
// The host silently selects macOS/Windows native style.
Button {
    contentItem: Text { text: control.text }
    background: Rectangle { radius: 12 }
}
```

The incorrect form makes a platform default part of the component architecture.
Native styles may reject these replacements at runtime. Select one customizable
style before QML loads and use it in tests and packaging, or retain the native
style and its supported customization surface.

## Exact QML Type Contract

**Correct**

```text
Declared minimum: Qt 6.6
Exact instantiated type: TextArea
Verified members: TextArea/TextEdit inherited-member documentation for Qt 6.6
Strict qmllint: 0 warnings
Runtime component creation: PASS
```

**Incorrect**

```text
Text has the desired property, so assign it to TextArea and remove it manually
if the generated project fails on the user's Qt SDK.
```

Visual similarity does not establish QML inheritance or minimum-version
availability. Preserve the intended behavior through an API verified on the
exact type.

## Acyclic Scrollable Editor Geometry

**Correct when the viewport has an explicit layout-owned height**

```qml
ScrollView {
    id: viewport
    clip: true

    TextArea {
        width: viewport.availableWidth
        height: Math.max(contentHeight, viewport.height)
    }
}
```

**Incorrect**

```qml
ScrollView {
    id: viewport

    TextArea {
        width: viewport.availableWidth
        implicitHeight: Math.max(contentHeight, viewport.availableHeight)
    }
}
```

The incorrect child derives implicit size from a viewport that can derive its
content size from the child. Runtime binding-loop warnings fail verification.

## Content-Safe Actions And Popup Rows

**Correct**

```qml
Button {
    implicitWidth: Math.max(theme.primaryActionMinimumWidth,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    text: qsTr("Save session settings")
}

RowLayout {
    width: ListView.view.width
    Text { Layout.fillWidth: true; elide: Text.ElideRight }
    Text { Layout.maximumWidth: parent.width * 0.45; elide: Text.ElideRight }
}
```

**Incorrect**

```qml
Button {
    width: 168
    text: qsTr("Save session settings")
}
```

Fixed widths are allowed only after the longest supported content and translated
expansion have been reviewed. Primary action meaning must not disappear behind
accidental elision; popup columns must divide available width deliberately and
remain within safe window bounds.

## QML-Creatable Type Shape

**Correct**

```cpp
class AppViewModel : public QObject {
    Q_OBJECT
    QML_ELEMENT
};
```

**Incorrect**

```cpp
class AppViewModel final : public QObject {
    Q_OBJECT
    QML_ELEMENT
};
```

Qt generates a wrapper derived from a QML-creatable type. The incorrect form
fails in generated QML type-registration code even when core targets and
headless tests pass.

Generated projects also run the baseline
`aimcpp_reject_final_qml_creatable_types` configure preflight over every QML
registration header. Passing that check is not a substitute for compiling the
generated Qt registration code and linking the complete graphical target.

## Full-Product Verification

**Correct**

```text
Core target: PASS
Qt Quick target with GUI enabled: PASS
All discovered tests: PASS
QML creation/interaction smoke: PASS
Final archive: VERIFIED
```

**Incorrect**

```text
Core target with GUI disabled: PASS
Qt SDK unavailable: skipped
Final Qt application: READY
```

The incorrect report promotes partial evidence into a product-wide claim. An
unbuilt requested surface is `NOT VERIFIED` and blocks final delivery.

## Layout Contract And Visual Acceptance

**Correct**

```text
Outer inset: spacing.xl
Task content max width: 720
Wide composition: centered task column + bounded secondary panel
Shared alignment lines: title/display/keypad left and right edges
Key grid: 4 equal columns, one control height, spacing.md gaps
Footer: inside task column safe bounds
Visual matrix: minimum/standard/wide × light/dark × empty/populated/error
```

```qml
Item {
    Layout.fillWidth: true
    Layout.maximumWidth: theme.taskMaximumWidth
    Layout.alignment: Qt.AlignHCenter
}
```

**Incorrect**

```text
The outer card fills the wide window.
The keypad keeps a small fixed width at the left edge.
The display stretches across the entire card.
Header actions and the footer use unrelated anchors.
Only one desktop screenshot was inspected.
```

The incorrect form can use layout containers and still have drifting edges,
unbalanced dead space, detached peripheral controls, and no proof of responsive
quality. Define geometry relationships before implementation and review the
rendered result across the required visual matrix.

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

**Correct project-module configuration**

```cmake
project(MyApp LANGUAGES CXX)

add_library(project_core)
target_sources(project_core
    PUBLIC FILE_SET CXX_MODULES FILES src/project/project.cppm
    PRIVATE src/project/project.cpp
)
set_property(TARGET project_core PROPERTY CXX_SCAN_FOR_MODULES ON)
```

**Incorrect experimental standard-library configuration**

```cmake
project(MyApp LANGUAGES CXX)
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "<gate-set-too-late>")
set(CMAKE_CXX_MODULE_STD ON)
```

The incorrect form adds an experimental standard-library module path that the
repository does not support. Remove the gate and `CMAKE_CXX_MODULE_STD`, use
standard headers in global module fragments, and preserve project modules.

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
