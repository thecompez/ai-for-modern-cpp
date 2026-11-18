# CMake 4.5: non-experimental `import std;`

CMake 4.5 made standard-library module integration non-experimental. The
`CMAKE_EXPERIMENTAL_CXX_IMPORT_STD` UUID gate is no longer required. This does
**not** guarantee working standard-library modules on every installation.

## Repository decision

- The repository's executable proof and generated Qt baseline continue to use
  standard headers in global module fragments, targeting CMake 3.30+.
- An explicitly requested project MAY adopt `import std;` with CMake 4.5+ if
  the selected compiler, standard library, Ninja generator, C++ standard, clean
  build, and tests are all verified. Do not silently migrate existing code.
- Keep application-owned `.cppm` modules and `FILE_SET CXX_MODULES`. Do not
  generate two competing source trees or automatic fallback macros.
- Do not carry over the old `CMAKE_CXX_COMPILER_IMPORT_STD`,
  `CMAKE_CXX_MODULE_STD`, or target `CXX_MODULE_STD` workflow to CMake 4.5.

## Supported combinations documented by CMake 4.5

| Compiler | Minimum |
| --- | --- |
| Clang + libc++ or libstdc++ | 18.1.2 |
| GCC on non-macOS | 15 |
| GCC on macOS | 16 |
| MSVC | Toolset 14.36 (Visual Studio 17.6) |

Only **Ninja** and **Ninja Multi-Config** support `import std` today; Ninja
1.11+ is required. CMake makes it available with C++20+ when module scanning
is enabled, but source-level library APIs still depend on compiler and library.
Ubuntu before 26.04 ships broken `libstdc++.modules.json` packages.

## Minimal independently testable example

`CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 4.5)
project(std_module_probe LANGUAGES CXX)
add_executable(std_module_probe main.cpp)
target_compile_features(std_module_probe PRIVATE cxx_std_23)
set_property(TARGET std_module_probe PROPERTY CXX_SCAN_FOR_MODULES ON)
```

`main.cpp`:

```cpp
import std;

int main()
{
    const std::vector<int> values{1, 2, 3};
    return values.size() == 3 ? 0 : 1;
}
```

Verify with the *actual* selected compiler and standard library:

```bash
cmake -S . -B build -G Ninja -DCMAKE_CXX_COMPILER=/path/to/c++
cmake --build build --parallel
./build/std_module_probe
```

The executable must exit successfully. This illustrative probe is not proof
of CI coverage or platform compatibility. For a production project, also
build every declared target and run the complete tests and Qt smoke checks.

## Metadata and troubleshooting

CMake 4.5 introduces `CMAKE_CXX_STDLIB_MODULES_JSON`, a **non-experimental**
optional override pointing to an existing valid metadata file *only if* the
compiler cannot discover one. It is not a UUID gate. Do not search the whole
system for guessed metadata, edit compiler installation files, or treat the
CMake version alone as proof of a functional `import std` toolchain.

A `module 'std' not found` error requires checking the exact compiler/stdlib,
CMake version, generator, `CXX_SCAN_FOR_MODULES`, installed metadata, and
the first configure/build error. Repair the actual unsupported combination.
Do not silently switch the project's architecture to make CI green.

CMake 4.5 also teaches AUTOMOC about module interface units, but that
integration requires **Qt 6.13+** and does not remove full Qt/QML validation.

## Primary references

- https://cmake.org/cmake/help/v4.5/manual/cmake-cxxmodules.7.html
- https://cmake.org/cmake/help/v4.5/release/4.5.html
- https://cmake.org/cmake/help/v4.5/variable/CMAKE_CXX_STDLIB_MODULES_JSON.html
