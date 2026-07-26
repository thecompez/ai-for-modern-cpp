# Cross-Platform Application Icon Scenarios

## EVAL-APP-001 — One Precomposed Bitmap For Every Platform

**Prompt**

```text
Use this rounded Apple application icon unchanged for macOS, iOS, Android,
Windows, Linux, and the 32-pixel logo inside the application header.
```

**Required behavior**

- Preserve the human-approved brand identity while separating Apple composition,
  non-Apple platform composition, Android layers, and the in-application mark.
- Reject use of an Apple pre-masked rounded icon as the Android adaptive
  foreground.
- Generate platform-native artifacts rather than copying one PNG everywhere.
- Verify the actual packaged surfaces before claiming completion.

**Forbidden behavior**

- Reusing the same precomposed bitmap unchanged on every platform.
- Adding another rounded mask around an already masked Apple composition.
- Treating a generated file list as visual verification.

**Rule coverage**: `APP-001` through `APP-010`, `PLT-003`, `GUI-026`,
`TST-007`, and `VER-010`.

## EVAL-APP-002 — Android Adaptive Icon Touches The Mask

**Rendered evidence**

```text
The product mark nearly touches the circular launcher boundary in App info.
The agent proposes adding another dark circular plate around the foreground.
```

**Required behavior**

- Inspect the adaptive foreground's meaningful alpha bounds.
- Keep critical content inside the centered 66 by 66 dp safe zone of the
  108 by 108 dp layer.
- Reduce optical scale and restore transparent inset.
- Preview circle, squircle, rounded-square, and aggressive OEM masks.
- Regenerate legacy and round resources independently when their composition
  requires different padding.

**Critical failure**

Adding another pre-masked circle to hide the safe-zone defect.

**Rule coverage**: `APP-004`, `APP-008`, `APP-010`, and `VER-010`.

## EVAL-APP-003 — Faded And Blurry Header Logo

**Observed interface**

```text
The launcher icon is correct, but the full-color brand mark in the mobile header
looks faded and soft. A 1024-pixel raster is loaded into a 40-pixel Image under a
parent whose disabled state changes opacity.
```

**Required behavior**

- Treat the in-application mark as a separate UI asset.
- Inspect parent opacity, disabled-state propagation, colorization, filtering,
  asynchronous loading, `sourceSize`, and device-pixel ratio.
- Use an SVG or size-appropriate lossless variants.
- Verify the actual header in light and dark appearance at normal and high DPR.

**Forbidden behavior**

- Increasing saturation or changing the master brand artwork before locating
  the rendering cause.
- Reusing a launcher or store icon blindly as a tiny interface glyph.

**Rule coverage**: `APP-002`, `APP-007`, `GUI-026`, and `GUI-030`.

## EVAL-APP-004 — Packaging Files Exist But Targets Do Not Reference Them

**Diff under review**

```text
resources/branding/generated/macos/MyApp.icns
resources/branding/generated/windows/MyApp.ico
resources/branding/generated/ios/Assets.xcassets
```

The files exist in the repository, but CMake does not add them to the owning
target and the installed Linux desktop file names a different icon.

**Expected findings**

- `APP-003` and `APP-009`: platform artifacts must be target-local and package
  referenced.
- macOS bundle resources require target source registration plus the bundle icon
  filename.
- Windows requires the `.rc` resource to be compiled into the executable.
- Linux desktop-entry `Icon=` must match the installed hicolor asset name.
- iOS asset catalogs or Icon Composer files must be part of the Xcode target.

**Rule coverage**: `APP-003`, `APP-006`, `APP-009`, `BLD-003`, and `PLT-003`.

## EVAL-APP-005 — Cache Confused With Artwork Failure

**Observed behavior**

```text
The APK contains the new adaptive icon, but the launcher still displays the old
icon after an in-place development install. The agent keeps changing the source
artwork without inspecting the installed package or launcher cache.
```

**Required behavior**

- Verify package resource bytes and manifest references first.
- Compare the built and installed package when possible.
- Uninstall the previous development package before reinstalling.
- Clear only the relevant launcher or development cache when needed.
- Keep the surface `NOT VERIFIED` until the new packaged icon is observed.

**Forbidden behavior**

- Reporting the icon fixed based only on regenerated PNGs.
- Repeatedly changing approved artwork to compensate for stale system state.

**Rule coverage**: `APP-010`, `APP-011`, `APP-012`, `VER-008`, and `VER-010`.
