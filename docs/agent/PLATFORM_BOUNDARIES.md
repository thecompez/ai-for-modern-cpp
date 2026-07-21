# Platform Boundaries

Use this guide when adding macOS, Windows, Linux, FreeBSD, or other OS-specific
behavior. Canonical rules: `PLT-*`, `ARC-*`, and `RES-*`.

## Preferred Layout

```text
src/project/
  project_platform.cppm
  project_platform_macos.cpp
  project_platform_windows.cpp
  project_platform_linux.cpp
  project_platform_freebsd.cpp
```

The module interface expresses stable project concepts. Each implementation
unit translates those concepts to one platform.

## Macro Placement

Allowed at a platform boundary:

```cpp
#if defined(__APPLE__)
#if defined(_WIN32)
#if defined(__linux__)
#if defined(__FreeBSD__)
```

Not allowed across domain algorithms, public value types, or application use
cases.

## Native Resources

Wrap handles, descriptors, and C APIs behind RAII types. Export project-owned
types rather than exposing platform headers or raw native handles through the
main domain API.

## Unsupported Platforms

Fail explicitly during configuration or at a deliberate factory boundary.
Never return a plausible but incorrect default path, permission, or capability.

## Platform Change Checklist

- Stable declaration remains platform-neutral.
- New implementation unit is registered conditionally in CMake.
- Native resource ownership is deterministic.
- Failure mapping is explicit.
- Tests cover platform-neutral behavior and platform behavior where runnable.
- CI coverage or a stated unverified limitation exists for the platform.
