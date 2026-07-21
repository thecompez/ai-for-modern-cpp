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
