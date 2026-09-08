# Cross-Platform Application Icons And Branding

Use this guide when a project creates, replaces, generates, packages, or reviews
an application icon, launcher icon, bundle icon, desktop-entry icon, store icon,
or in-application brand mark. Canonical rules: `APP-*`, plus `INI-*`,
`ARC-*`, `PLT-*`, `GUI-017`, `GUI-018`, `GUI-026`, `GUI-030`, `BLD-003`,
`TST-007`, `VER-008`, and `VER-010`.

Primary platform references:

- Apple app icons:
  https://developer.apple.com/design/human-interface-guidelines/app-icons/
- Apple Icon Composer:
  https://developer.apple.com/icon-composer/
- Android adaptive icons:
  https://developer.android.com/develop/ui/views/launch/icon_design_adaptive
- Windows app-icon construction:
  https://learn.microsoft.com/windows/apps/design/iconography/app-icon-construction
- freedesktop.org Icon Theme Specification:
  https://specifications.freedesktop.org/icon-theme/latest/
- Qt Android application icon property:
  https://doc.qt.io/qt-6/cmake-target-property-qt-android-app-icon.html
- Qt iOS platform notes:
  https://doc.qt.io/qt-6/ios-platform-notes.html

The goal is one recognizable product identity expressed through native platform
artifacts. It is not one raster file copied unchanged into every platform.

This guide interprets the short `APP-*` rules. It does not authorize an agent to
create branding before the project-name and identity gate has passed, and it does
not replace the platform vendor documentation for a selected SDK or packaging
model.

## Required Branding Pass

Before generating files or editing CMake, record:

```text
Approved product name:
Canonical brand-mark source:
Apple-specific icon composition, if supplied:
Non-Apple icon composition, if supplied:
In-application mark source:
Supported platforms:
Minimum OS and Qt versions:
Packaging model per platform:
Light, dark, clear, tinted, and monochrome requirements:
Smallest rendered context per platform:
Generation tool and deterministic command:
Verification devices, emulators, masks, and desktop environments:
```

Do not invent branding while `INI-001` through `INI-003` are unresolved. A
placeholder such as `MyApp` is documentation syntax, not permission to create a
real product identity.

## Asset Ownership Model

Treat the brand mark, platform icon compositions, generated native files, and
in-application logos as different responsibilities.

```text
resources/
  branding/
    source/
      brand-mark.svg
      brand-mark.png
      app-icon-apple-1024.png
      app-icon-platform-1024.png
    generated/
      windows/
      macos/
      linux/
      android/
      ios/
ui/
  assets/
    brand/
      app-mark.svg
      app-mark-128.png
      app-mark-256.png
      app-mark-512.png
tools/
  generate_app_icons.py
  verify_app_icons.py
```

Projects may use a smaller structure when fewer surfaces exist, but they must
preserve these ownership boundaries:

- `source/` contains human-approved masters and is never overwritten by a
  generator.
- `generated/` contains deterministic platform artifacts and is never hand
  edited.
- `ui/assets/brand/` contains the mark rendered inside the application. It is
  not implicitly the same file as a launcher or store icon.
- Native packaging files belong to the target or platform package, not the QML
  module namespace.

Do not put every image into a generic `assets/`, `misc/`, or `icons/` dumping
bucket without ownership or generation provenance.

## Canonical Source Contract

- Prefer vector artwork for the canonical mark when gradients and effects remain
  faithfully representable; otherwise use a lossless high-resolution PNG.
- Keep at least one 1024 by 1024 source for square app-icon compositions.
- Do not upscale a smaller raster and call it a master.
- Preserve aspect ratio and optical center. Geometric centering alone may be
  insufficient for asymmetric marks.
- Keep text out of the icon unless it is essential to the brand. The application
  name is already shown near the icon in many system surfaces.
- Keep critical details thick and simple enough to survive the smallest required
  context.
- Record the intended color space. Use sRGB as the portable default unless a
  platform-specific wide-gamut path is deliberately verified.
- Do not silently recolor, reshape, add a plate, add a shadow, or crop an
  approved source. Platform adaptation must be explicit and reviewable.

## One Identity, Multiple Compositions

A product may have:

1. one canonical mark;
2. an Apple-specific app-icon composition;
3. a non-Apple composition for Windows, Linux, and Android;
4. a simplified monochrome mark;
5. a separate in-application mark.

These variations must preserve the same recognizable core shape and color
identity. They may change padding, background treatment, depth, masking
assumptions, and layer structure to match the platform.

Do not use a precomposed Apple rounded-square icon as the Android adaptive
foreground. Do not apply another rounded mask to an Apple composition that
already includes an approved plate. Double masking produces cramped artwork,
jagged corners, or an unintended dark ring.

## Apple Platforms

### iOS And iPadOS

Current Apple icon workflows support a layered 1024 by 1024 design across iOS,
iPadOS, and macOS. Prefer Icon Composer when the selected Xcode and deployment
path support it. Preserve a compatibility asset-catalog path when the project
must build with an older Apple toolchain.

- Supply square, unmasked layers; the system applies the final rounded shape.
- Keep the background full-bleed and opaque.
- Keep primary content centered and away from masked corners.
- Prefer clearly defined foreground edges. Soft feathered boundaries can render
  poorly with system-generated highlights and shadows.
- Preserve core visual features across default, dark, clear, tinted, and mono
  appearances. Do not swap the identity between variants.
- Prefer vector layers when possible; use lossless PNG for raster artwork.
- Do not bake a second rounded rectangle into layers intended for system masking.
- Verify the archived product and App Store validation result rather than only
  checking source images.

Preferred modern source shape:

```text
resources/branding/generated/ios/MyApp.icon
```

Compatibility asset-catalog shape:

```text
resources/branding/generated/ios/Assets.xcassets/
  AppIcon.appiconset/
    Contents.json
    AppIcon-1024.png
    ...
```

Example compatibility CMake shape:

```cmake
if(IOS)
    set(appIconCatalog
        "${CMAKE_CURRENT_SOURCE_DIR}/resources/branding/generated/ios/Assets.xcassets"
    )
    target_sources(MyApp PRIVATE "${appIconCatalog}")
    set_source_files_properties(
        "${appIconCatalog}"
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )
    set_target_properties(MyApp PROPERTIES
        XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME AppIcon
    )
endif()
```

Do not edit the generated Xcode project as the source of truth.

### macOS

- Use the approved Apple composition when the product provides one.
- Prefer the same layered Apple source used for iOS when the current Xcode path
  supports it.
- For a traditional Qt bundle or compatibility build, generate a valid
  multi-representation `.icns` file.
- Do not add another rounded rectangle, shadow, highlight, or glossy plate around
  an icon that already contains the approved Apple composition.
- Inspect Dock, Finder, Launchpad, Spotlight, application switcher, and About at
  normal and Retina scale.

Qt/CMake compatibility shape:

```cmake
if(APPLE AND NOT IOS)
    set(macAppIcon
        "${CMAKE_CURRENT_SOURCE_DIR}/resources/branding/generated/macos/MyApp.icns"
    )
    set_source_files_properties(
        "${macAppIcon}"
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources
    )
    target_sources(MyApp PRIVATE "${macAppIcon}")
    set_target_properties(MyApp PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_ICON_FILE "MyApp.icns"
    )
endif()
```

The source file must be added to the target. Setting only
`MACOSX_BUNDLE_ICON_FILE` does not package an arbitrary source path.

## Android

Android launcher artwork is a layered, masked system resource, not a normal
square bitmap.

### Adaptive Icon Contract

- Define separate foreground and background layers.
- Size each layer to 108 by 108 dp.
- Keep critical foreground content inside the centered 66 by 66 dp safe zone.
- Keep meaningful logo content between 48 by 48 dp and 66 by 66 dp unless real
  mask previews justify a smaller optical size.
- Reserve the outer 18 dp on every side for OEM masking and visual effects.
- Do not put a circular, squircle, rounded-square, or shadow mask around the
  adaptive foreground.
- Prefer vector foreground artwork when the mark can be represented faithfully.
- Provide a monochrome layer for themed icons when the supported Android range
  uses it.
- Preview at least circle, squircle, rounded square, and an aggressive OEM mask.

A mark that touches the visible boundary in App info or the launcher is not
fixed by adding another circle. Reduce the foreground scale and restore
transparent breathing room inside the 108 dp layer.

### Legacy And Round Icons

- Generate legacy density-specific PNGs separately from adaptive layers.
- Preserve optical padding; do not simply flatten a full-size adaptive preview.
- Provide `android:roundIcon` only when the project deliberately supplies and
  verifies a round resource.
- A round legacy icon may use transparent corners, but its central composition
  still needs breathing room.
- Verify `mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, and `xxxhdpi` outputs when those
  buckets are generated.

Recommended package shape:

```text
android/res/
  mipmap-mdpi/ic_launcher.png
  mipmap-hdpi/ic_launcher.png
  mipmap-xhdpi/ic_launcher.png
  mipmap-xxhdpi/ic_launcher.png
  mipmap-xxxhdpi/ic_launcher.png
  mipmap-anydpi-v26/ic_launcher.xml
  mipmap-anydpi-v26/ic_launcher_round.xml
  drawable/ic_launcher_foreground.xml
  drawable/ic_launcher_monochrome.xml
  values/ic_launcher_background.xml
```

Qt 6.9 or newer target-local shape:

```cmake
if(ANDROID)
    set_target_properties(MyApp PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR
            "${CMAKE_CURRENT_SOURCE_DIR}/resources/branding/generated/android"
        QT_ANDROID_APP_ICON "@mipmap/ic_launcher"
    )
endif()
```

For an older Qt version or custom manifest, preserve the same resource contract
through the managed `AndroidManifest.xml`. Do not define conflicting icon names
in Qt-generated and custom manifests.

## Windows

### Win32 Desktop Contract

- Produce a multi-representation `.ico` file.
- Include at least 16, 24, 32, 48, and 256 pixel representations.
- Include 20, 30, 36, 40, 60, 64, 72, 80, 96, and 128 pixel variants when the
  selected packaging model and generator support them reliably.
- Use 32-bit color with alpha. The 256 pixel representation may use PNG
  compression inside the ICO container.
- Tune small sizes deliberately. A 16 pixel image may need simplified detail and
  optical adjustment rather than a blind downscale.
- Prefer a transparent background unless the approved identity requires a plate;
  verify light and dark system themes either way.

Resource shape:

```rc
IDI_APP_ICON ICON "resources/branding/generated/windows/MyApp.ico"
```

```cmake
if(WIN32)
    target_sources(MyApp PRIVATE
        resources/branding/generated/windows/MyApp.rc
    )
endif()
```

For MSIX or Windows App SDK packaging, generate the package asset family required
by that packaging model in addition to the Win32 ICO. The ICO alone does not
populate every package, Store, or tile surface.

Verify title bar, taskbar, Start, Search, Explorer, Alt+Tab, shortcuts, and the
installed-app surface at multiple display scale factors.

## Linux Desktops

- Install application icons into the `hicolor` fallback theme.
- Provide a scalable SVG under `hicolor/scalable/apps` when the artwork is safe
  to render as SVG.
- Provide a 48 by 48 PNG at minimum; common additional sizes include 16, 22, 24,
  32, 48, 64, 128, 256, and 512.
- Use one stable icon name without a filename extension in the desktop entry.
- Install the `.desktop` file under `share/applications` and icons under
  `share/icons/hicolor/<size>/apps`.
- Keep the fallback icon visually neutral enough to coexist with different
  desktop themes.
- Do not embed a machine-specific absolute path in the installed desktop entry.

Example:

```ini
[Desktop Entry]
Type=Application
Name=MyApp
Exec=MyApp
Icon=my-app
Categories=Utility;
```

```cmake
if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(FILES resources/branding/generated/linux/my-app.desktop
        DESTINATION share/applications
    )
    install(FILES resources/branding/generated/linux/hicolor/48x48/apps/my-app.png
        DESTINATION share/icons/hicolor/48x48/apps
    )
    install(FILES resources/branding/generated/linux/hicolor/scalable/apps/my-app.svg
        DESTINATION share/icons/hicolor/scalable/apps
    )
endif()
```

Verify at least one GNOME-family and one KDE-family environment when both are
claimed. AppImage, Flatpak, Snap, Debian, and RPM packaging may require
additional metadata, but they must preserve the same stable icon identity.

## In-Application Brand Mark

The logo rendered in a header, About page, onboarding screen, or empty state is
an interface asset, not a launcher artifact.

- Select the approved in-application mark explicitly. A product may intentionally
  use its Apple composition inside the app, but this is a product decision, not
  a cross-platform default.
- Keep `opacity: 1.0` unless disabled or transient state is intentional.
- Avoid scaling a 1024 pixel raster down to a 24- or 40-pixel header on every
  frame. Provide an SVG or size-appropriate lossless variants.
- For Qt Quick raster images, set a deliberate `sourceSize`, preserve aspect
  ratio, and verify whether `mipmap` improves or blurs the actual target size.
- Do not recolor a full-color brand icon through a generic disabled-state or
  toolbar-icon component.
- Keep the mark out of button-opacity inheritance and disabled parent opacity.
- Test on light and dark surfaces, at device pixel ratios 1 and 2 or higher, and
  at the smallest mobile header size.
- Provide an accessible name when the logo conveys identity or navigation.

Example QML boundary:

```qml
Image {
    id: appMark
    source: Qt.resolvedUrl("../assets/brand/app-mark-128.png")
    sourceSize.width: Math.round(width * Screen.devicePixelRatio)
    sourceSize.height: Math.round(height * Screen.devicePixelRatio)
    fillMode: Image.PreserveAspectFit
    asynchronous: false
    cache: true
    opacity: 1.0
}
```

The exact `sourceSize` and raster variant depend on the product. Rendered evidence
must decide whether the mark is crisp; copying this snippet is not proof.

## Deterministic Generation

A generator must:

- accept only approved source assets and explicit platform profiles;
- preserve aspect ratio and optical center;
- encode Android foreground scale and safe-zone policy as named constants;
- generate all required density and container variants deterministically;
- avoid upscaling above the master source resolution;
- preserve or remove alpha only where the target platform requires it;
- write generated files only under the generated platform boundary;
- fail when a required source, external encoder, size, or output is missing;
- print the exact generated files and dimensions;
- be idempotent.

Generated files may be committed when platform packaging requires ready assets or
when reproducible generation tools are unavailable in normal builds. The project
must choose and document one policy. Never hand-edit a generated icon and leave
the generator stale.

## Verification Contract

Static verification should check:

- source masters exist and meet minimum dimensions;
- source and generated files decode successfully;
- no unintended resize or aspect-ratio distortion occurred;
- every required ICO representation exists;
- `.icns`, Icon Composer, or Apple asset-catalog outputs are valid and
  target-referenced;
- Android adaptive XML references existing foreground, background, round, and
  monochrome resources;
- Android meaningful foreground bounds stay inside the declared safe-zone policy;
- iOS compatibility asset-catalog JSON references existing files and the expected
  icon set;
- Linux desktop-entry icon names match installed hicolor assets;
- CMake references project-relative existing paths;
- native package identifiers and filenames derive from the approved product
  identity.

Rendered verification must inspect the actual packaged product, not only source
PNGs:

| Platform | Required contexts |
|---|---|
| Android | launcher masks, App info, Settings, overview/recents, themed icon when supported |
| iOS/iPadOS | Home Screen, Settings, search, notifications, archive validation |
| macOS | Dock, Finder, Launchpad, Spotlight, app switcher, About |
| Windows | title bar, taskbar, Start, Search, Explorer, Alt+Tab, installed apps |
| Linux | application menu, dock/task manager, desktop entry, package/AppImage context |
| In-app | mobile and desktop headers, About, light/dark, DPR 1 and high-DPI |

Record the exact device, OS, launcher or desktop environment, mask, appearance,
package type, and result. A generated file list is not visual evidence.

## Cache And Reinstallation

Operating systems and launchers cache application icons. When a newly generated
icon does not appear:

1. verify the built package contains the new bytes and resource references;
2. compare checksums with the installed package when possible;
3. uninstall the previous mobile package before reinstalling;
4. clear only the relevant development launcher or packaging cache when needed;
5. do not keep changing artwork until the package and cache path are proven.

Cache behavior is a diagnostic concern, not permission to report an unverified
icon as fixed.

## Common Failure Patterns

### One Precomposed Bitmap Everywhere

**Incorrect**

```text
apple-rounded-icon.png
    → Android foreground
    → Windows ICO
    → Linux icon
    → in-app 24 px header
```

This confuses brand identity with platform composition and commonly causes
Android double masking, cramped safe zones, blurred headers, and poor small-size
Windows rendering.

**Correct**

```text
canonical mark
    → Apple composition → iOS/macOS icon workflow
    → platform composition → Android layers + Windows ICO + Linux hicolor
    → UI mark → size-appropriate in-app asset
```

### Android Mark Touches The Mask

**Incorrect response**: add another circular background around the foreground.

**Correct response**: inspect meaningful foreground bounds, reduce optical scale,
restore transparent inset inside the 108 dp layer, and preview multiple masks.

### Double-Rounded Apple Icon

**Incorrect response**: take an approved rounded Apple composition and apply a
second rounded-rectangle clipping mask during generation.

**Correct response**: identify whether the input is an unmasked layer source or
an already approved composition, then apply exactly the packaging transformation
required by the selected Apple workflow.

### Faded In-App Logo

Inspect parent opacity, disabled-state propagation, colorization, asynchronous
loading, filtering, `sourceSize`, and raster downscaling. Do not compensate by
increasing saturation or changing the master artwork before locating the render
cause.

## Final Acceptance Checklist

- [ ] Product name and icon sources are human-approved.
- [ ] Canonical mark, Apple composition, non-Apple composition, and UI mark have
      explicit ownership.
- [ ] No platform receives another platform's pre-masked artifact by accident.
- [ ] Apple assets use the selected layered, asset-catalog, or bundle workflow
      without double masking.
- [ ] Android uses adaptive foreground/background layers, safe-zone-aware scale,
      and monochrome support where required.
- [ ] Windows has a verified multi-representation ICO and package assets when
      applicable.
- [ ] Linux installs a stable icon name into hicolor plus a matching desktop
      entry.
- [ ] In-app marks are crisp, full-opacity, and verified at actual header sizes.
- [ ] Generation is deterministic, idempotent, and not contradicted by hand edits.
- [ ] Static validation passes for every generated format and resource reference.
- [ ] Rendered verification covers every claimed platform and system context.
- [ ] Cache or stale-install effects were ruled out with package evidence.
- [ ] The final report marks unavailable SDKs, devices, stores, or package
      contexts `NOT VERIFIED`.
