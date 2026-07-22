cmake_minimum_required(VERSION 3.30)

if(NOT DEFINED AIMCPP_SOURCE_DIR)
    message(FATAL_ERROR "AIMCPP_SOURCE_DIR is required")
endif()

function(assert_file_exists relativePath)
    if(NOT EXISTS "${AIMCPP_SOURCE_DIR}/${relativePath}")
        message(FATAL_ERROR "Required knowledge surface is missing: ${relativePath}")
    endif()
endfunction()

function(assert_file_absent relativePath)
    if(EXISTS "${AIMCPP_SOURCE_DIR}/${relativePath}")
        message(FATAL_ERROR "Obsolete knowledge surface still exists: ${relativePath}")
    endif()
endfunction()

function(assert_file_contains relativePath expectedText)
    assert_file_exists("${relativePath}")
    file(READ "${AIMCPP_SOURCE_DIR}/${relativePath}" content)
    string(FIND "${content}" "${expectedText}" position)
    if(position EQUAL -1)
        message(FATAL_ERROR
            "${relativePath} does not contain required contract text: ${expectedText}"
        )
    endif()
endfunction()

function(assert_file_not_contains relativePath forbiddenText)
    assert_file_exists("${relativePath}")
    file(READ "${AIMCPP_SOURCE_DIR}/${relativePath}" content)
    string(FIND "${content}" "${forbiddenText}" position)
    if(NOT position EQUAL -1)
        message(FATAL_ERROR
            "${relativePath} contains forbidden active configuration: ${forbiddenText}"
        )
    endif()
endfunction()

function(assert_text_before relativePath firstText secondText)
    assert_file_exists("${relativePath}")
    file(READ "${AIMCPP_SOURCE_DIR}/${relativePath}" content)
    string(FIND "${content}" "${firstText}" firstPosition)
    string(FIND "${content}" "${secondText}" secondPosition)
    if(firstPosition EQUAL -1 OR secondPosition EQUAL -1 OR
       NOT firstPosition LESS secondPosition)
        message(FATAL_ERROR
            "${relativePath} must place '${firstText}' before '${secondText}'"
        )
    endif()
endfunction()

set(requiredSurfaces
    AGENTS.md
    README.md
    docs/REVIEW.md
    docs/agent/README.md
    docs/agent/START_PROJECT.md
    docs/agent/MODULES.md
    docs/agent/CMAKE_AND_TOOLCHAINS.md
    docs/agent/PROJECT_CMAKE_BASELINE.md
    docs/agent/QT_QUICK_UI.md
    docs/agent/COMMON_FAILURES.md
    docs/agent/PATTERNS.md
    docs/agent/TESTING_AND_VERIFICATION.md
    evals/README.md
    evals/project_initiation.md
    evals/toolchains.md
    evals/reflection.md
    evals/ui_and_syntax.md
    .agents/skills/source-command-add-module/SKILL.md
    .agents/skills/source-command-start-project/SKILL.md
    .agents/skills/source-command-start-project/agents/openai.yaml
    .agents/skills/source-command-implement/SKILL.md
    .agents/skills/source-command-test/SKILL.md
    .agents/skills/source-command-design-qt-quick-ui/SKILL.md
    .agents/skills/source-command-release/SKILL.md
    .claude/commands/add-module.md
    .claude/commands/start-project.md
    .claude/commands/implement.md
    .claude/commands/test.md
    .claude/commands/design-qt-quick-ui.md
    .claude/commands/release.md
    .github/workflows/ci.yml
    scripts/verify-linux.sh
    cmake/AimcppProjectChecks.cmake
    tests/project_checks.cmake
    tests/qt_quick_baseline_integration.cmake
    tests/fixtures/qt_quick_baseline/CMakeLists.txt
    tests/fixtures/qt_quick_baseline/cmake/AimcppProjectChecks.cmake
    tests/fixtures/qt_quick_baseline/src/domain/app_domain.cppm
    tests/fixtures/qt_quick_baseline/src/domain/app_domain.cpp
    tests/fixtures/qt_quick_baseline/src/presentation/app_view_model.hpp
    tests/fixtures/qt_quick_baseline/src/presentation/app_view_model.cpp
    tests/fixtures/qt_quick_baseline/src/bootstrap/main.cpp
    tests/fixtures/qt_quick_baseline/tests/app_tests.cpp
    tests/fixtures/qt_quick_baseline/ui/Main.qml
    tests/fixtures/qt_quick_baseline/ui/pages/HomePage.qml
    tests/fixtures/qt_quick_baseline/ui/components/PrimaryActionButton.qml
    tests/fixtures/qt_quick_baseline/ui/components/StatusPanel.qml
    tests/fixtures/qt_quick_baseline/ui/theme/Theme.qml
)

foreach(surface IN LISTS requiredSurfaces)
    assert_file_exists("${surface}")
endforeach()

assert_file_absent("cmake/AimcppImportStd.cmake")
assert_file_absent("scripts/bootstrap-linux-cmake.sh")
assert_file_absent("tests/import_std_metadata.cmake")

foreach(ruleId IN ITEMS
    KNO-005
    INI-001
    INI-002
    INI-003
    INI-004
    MOD-009
    MOD-010
    MOD-011
    MOD-012
    GUI-019
    GUI-020
    GUI-021
    GUI-022
    GUI-023
    GUI-024
    GUI-025
    GUI-026
    GUI-027
    GUI-028
    GUI-029
    GUI-030
    GUI-031
    GUI-032
    GUI-033
    BLD-004
    BLD-005
    BLD-009
    BLD-013
    BLD-014
    BLD-015
    BLD-016
    BLD-017
    VER-002
    VER-007
    VER-008
    VER-009
    VER-010
    VER-011
    VER-012
    TST-007
    TST-008
    TST-009
    TST-010
    REP-008
    REP-009
    REP-010
)
    assert_file_contains("AGENTS.md" "${ruleId}")
endforeach()

foreach(reviewRule IN ITEMS
    INI-001
    INI-002
    INI-003
    INI-004
    MOD-010
    GUI-020
    GUI-021
    GUI-022
    GUI-023
    GUI-024
    GUI-025
    GUI-026
    GUI-027
    GUI-028
    GUI-029
    GUI-030
    GUI-031
    GUI-032
    GUI-033
    BLD-005
    BLD-013
    BLD-014
    BLD-015
    BLD-016
    BLD-017
    TST-007
    TST-008
    TST-009
    TST-010
    VER-008
    VER-009
    VER-010
    VER-011
    VER-012
    REP-008
    REP-009
    REP-010
)
    assert_file_contains("docs/REVIEW.md" "${reviewRule}")
endforeach()

set(activeBuildSurfaces
    CMakeLists.txt
    .github/workflows/ci.yml
    scripts/verify-linux.sh
    docs/agent/PROJECT_CMAKE_BASELINE.md
    .agents/skills/source-command-add-module/SKILL.md
    .agents/skills/source-command-implement/SKILL.md
    .agents/skills/source-command-test/SKILL.md
    .claude/commands/add-module.md
    .claude/commands/implement.md
    .claude/commands/test.md
)

set(forbiddenBuildTokens
    CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
    CMAKE_CXX_COMPILER_IMPORT_STD
    CMAKE_CXX_STDLIB_MODULES_JSON
    CMAKE_CXX_MODULE_STD
    CXX_MODULE_STD
    AIMCPP_STDLIB_MODE
    AIMCPP_USE_IMPORT_STD
    libc++.modules.json
    libstdc++.modules.json
)

foreach(surface IN LISTS activeBuildSurfaces)
    foreach(token IN LISTS forbiddenBuildTokens)
        assert_file_not_contains("${surface}" "${token}")
    endforeach()
endforeach()

set(productionSources
    src/modern_cpp_agent/modern_cpp_agent.cppm
    src/modern_cpp_agent/modern_cpp_agent.cpp
    src/main.cpp
    tests/core_tests.cpp
)

foreach(source IN LISTS productionSources)
    assert_file_not_contains("${source}" "import std")
    assert_file_not_contains("${source}" "AIMCPP_USE_IMPORT_STD")
endforeach()

set(qtFixtureSources
    tests/fixtures/qt_quick_baseline/src/domain/app_domain.cppm
    tests/fixtures/qt_quick_baseline/src/domain/app_domain.cpp
    tests/fixtures/qt_quick_baseline/src/presentation/app_view_model.cpp
    tests/fixtures/qt_quick_baseline/src/bootstrap/main.cpp
    tests/fixtures/qt_quick_baseline/tests/app_tests.cpp
)

foreach(source IN LISTS qtFixtureSources)
    assert_file_not_contains("${source}" "import std")
endforeach()

assert_text_before(
    "tests/fixtures/qt_quick_baseline/src/domain/app_domain.cppm"
    "module;"
    "#include <"
)
assert_text_before(
    "tests/fixtures/qt_quick_baseline/src/domain/app_domain.cppm"
    "#include <"
    "export module my.app.domain;"
)

file(SHA256
    "${AIMCPP_SOURCE_DIR}/cmake/AimcppProjectChecks.cmake"
    projectChecksHash
)
file(SHA256
    "${AIMCPP_SOURCE_DIR}/tests/fixtures/qt_quick_baseline/cmake/AimcppProjectChecks.cmake"
    fixtureProjectChecksHash
)
if(NOT projectChecksHash STREQUAL fixtureProjectChecksHash)
    message(FATAL_ERROR
        "The generated Qt fixture must keep AimcppProjectChecks.cmake synchronized"
    )
endif()

assert_text_before(
    "src/modern_cpp_agent/modern_cpp_agent.cppm"
    "module;"
    "#include <"
)
assert_text_before(
    "src/modern_cpp_agent/modern_cpp_agent.cppm"
    "#include <"
    "export module modern.cpp.agent;"
)
assert_text_before(
    "src/modern_cpp_agent/modern_cpp_agent.cpp"
    "module;"
    "#include <"
)
assert_text_before(
    "src/modern_cpp_agent/modern_cpp_agent.cpp"
    "#include <"
    "module modern.cpp.agent;"
)

foreach(consumer IN ITEMS src/main.cpp tests/core_tests.cpp)
    assert_text_before("${consumer}" "#include <" "import modern.cpp.agent;")
endforeach()

file(GLOB_RECURSE projectHeaders
    "${AIMCPP_SOURCE_DIR}/src/*.h"
    "${AIMCPP_SOURCE_DIR}/src/*.hpp"
)
if(projectHeaders)
    message(FATAL_ERROR
        "Project-owned headers are forbidden in the executable proof: ${projectHeaders}"
    )
endif()

foreach(cmakeShape IN ITEMS
    "FILE_SET CXX_MODULES"
    "CXX_SCAN_FOR_MODULES ON"
    "AIMCPP_PROJECT_MODULES=ON"
    "AIMCPP_STANDARD_LIBRARY=HEADERS"
)
    assert_file_contains("CMakeLists.txt" "${cmakeShape}")
endforeach()

assert_file_contains("CMakeLists.txt" "NAME core_tests")
assert_file_contains("CMakeLists.txt" "NAME knowledge_contract")
assert_file_contains("CMakeLists.txt" "NAME project_checks")

foreach(startGuideText IN ITEMS
    "What should the project be called?"
    "Do not create code"
    "exact commit SHA"
    "$source-command-start-project"
    "/start-project"
)
    assert_file_contains("docs/agent/START_PROJECT.md" "${startGuideText}")
endforeach()

foreach(startWorkflow IN ITEMS
    .agents/skills/source-command-start-project/SKILL.md
    .claude/commands/start-project.md
)
    assert_file_contains("${startWorkflow}" "What should the project be called?")
    assert_file_contains("${startWorkflow}" "stop")
    assert_file_contains("${startWorkflow}" "exact revision")
endforeach()

foreach(moduleGuideText IN ITEMS
    "Never write `import std;`"
    "global module fragment"
    "FILE_SET CXX_MODULES"
    "CXX_SCAN_FOR_MODULES"
)
    assert_file_contains("docs/agent/MODULES.md" "${moduleGuideText}")
endforeach()

foreach(toolchainGuideText IN ITEMS
    "One source path"
    "project-owned modules"
    "standard-library headers"
    "target_include_directories"
    "src/presentation"
    "default `all` target"
    "aimcpp_reject_final_qml_creatable_types"
    "customizable Qt Quick"
    "strict `qmllint`"
    "warning-fatal runtime"
    "QT_RESOURCE_ALIAS"
    "QT_QML_OUTPUT_DIRECTORY"
    "RUNTIME_OUTPUT_DIRECTORY"
)
    assert_file_contains("docs/agent/CMAKE_AND_TOOLCHAINS.md" "${toolchainGuideText}")
endforeach()

foreach(baselineText IN ITEMS
    "project(MyApp"
    "FILE_SET CXX_MODULES"
    "CXX_SCAN_FOR_MODULES ON"
    "qt_add_qml_module(MyApp"
    "target_include_directories(MyApp"
    "src/presentation"
    "QT_KNOWN_POLICY_QTP0004"
    "-DMY_APP_BUILD_GUI=ON"
    "--target all"
    "NOT VERIFIED"
    "AimcppProjectChecks.cmake"
    "aimcpp_reject_final_qml_creatable_types"
    "MY_APP_QT_QUICK_CONTROLS_STYLE"
    "MyApp_qmllint_strict"
    "--max-warnings 0"
    "QT_FATAL_WARNINGS=1"
    "--smoke-test"
    "QT_RESOURCE_ALIAS"
    "QT_QML_OUTPUT_DIRECTORY"
    "RUNTIME_OUTPUT_DIRECTORY"
    "WORKING_DIRECTORY"
    "-M MyApp"
)
    assert_file_contains("docs/agent/PROJECT_CMAKE_BASELINE.md" "${baselineText}")
endforeach()

assert_file_not_contains(
    "docs/agent/PROJECT_CMAKE_BASELINE.md"
    "\"\${CMAKE_CURRENT_SOURCE_DIR}/ui/Main.qml\""
)

foreach(relativeQmlPath IN ITEMS
    "ui/Main.qml"
    "ui/pages/HomePage.qml"
    "ui/components/PrimaryActionButton.qml"
    "ui/components/StatusPanel.qml"
    "ui/theme/Theme.qml"
)
    assert_file_contains(
        "docs/agent/PROJECT_CMAKE_BASELINE.md"
        "${relativeQmlPath}"
    )
endforeach()

assert_text_before(
    "docs/agent/PROJECT_CMAKE_BASELINE.md"
    "QT_RESOURCE_ALIAS"
    "qt_add_qml_module(MyApp"
)
assert_text_before(
    "docs/agent/PROJECT_CMAKE_BASELINE.md"
    "set(QT_QML_OUTPUT_DIRECTORY"
    "qt_add_qml_module(MyApp"
)
assert_text_before(
    "docs/agent/PROJECT_CMAKE_BASELINE.md"
    "qt_add_executable(MyApp"
    "RUNTIME_OUTPUT_DIRECTORY"
)

assert_text_before(
    "docs/agent/PROJECT_CMAKE_BASELINE.md"
    "qt_policy(SET QTP0004 NEW)"
    "qt_add_qml_module(MyApp"
)
assert_text_before(
    "docs/agent/PROJECT_CMAKE_BASELINE.md"
    "qt_add_qml_module(MyApp"
    "target_include_directories(MyApp"
)

foreach(qtGuideText IN ITEMS
    "target_include_directories"
    "src/presentation"
    "QML_ELEMENT"
    "*_qmltyperegistrations.cpp"
    "must not be declared `final`"
    "full default target"
    "QML creation/interaction smoke check"
    "Layout Contract"
    "Alignment And Rhythm Audit"
    "Content Balance And Empty Space"
    "Visual Acceptance Matrix"
    "minimum, standard, and wide"
    "aimcpp_reject_final_qml_creatable_types"
    "Qt Quick Controls Style Contract"
    "Exact QML API Compatibility"
    "Acyclic Geometry And Scrollable Content"
    "Content-Safe Controls, Popups, And Dialogs"
    "Portable Typography"
    "fixed-delay launch"
    "QT_RESOURCE_ALIAS"
    "QT_QML_OUTPUT_DIRECTORY"
    "RUNTIME_OUTPUT_DIRECTORY"
    "-M MyApp"
)
    assert_file_contains("docs/agent/QT_QUICK_UI.md" "${qtGuideText}")
endforeach()

foreach(failureText IN ITEMS
    "module 'std' not found"
    "undeclared"
    "target_include_directories"
    "*_qmltyperegistrations.cpp"
    "base is marked `final`"
    "Partial Success Is Not Product Success"
    "non-existent property"
    "does not support customization"
    "Binding loop detected"
    "missing font family"
    "A Window That Opens Can Still Fail Verification"
    "specified with an absolute path and is used in a Qt resource"
    "Please set the QT_RESOURCE_ALIAS property"
    "errno=21 (Is a directory)"
    "output-path collision"
)
    assert_file_contains("docs/agent/COMMON_FAILURES.md" "${failureText}")
endforeach()

foreach(skill IN ITEMS
    .agents/skills/source-command-add-module/SKILL.md
    .agents/skills/source-command-implement/SKILL.md
    .claude/commands/add-module.md
    .claude/commands/implement.md
)
    assert_file_contains("${skill}" "global module fragment")
endforeach()

foreach(qtWorkflow IN ITEMS
    .agents/skills/source-command-design-qt-quick-ui/SKILL.md
    .claude/commands/design-qt-quick-ui.md
)
    assert_file_contains("${qtWorkflow}" "target-local")
    assert_file_contains("${qtWorkflow}" "*_qmltyperegistrations.cpp")
    assert_file_contains("${qtWorkflow}" "must not be `final`")
    assert_file_contains("${qtWorkflow}" "full default")
    assert_file_contains("${qtWorkflow}" "minimum, standard, and wide")
    assert_file_contains("${qtWorkflow}" "accidental dead space")
    assert_file_contains("${qtWorkflow}" "aimcpp_reject_final_qml_creatable_types")
    assert_file_contains("${qtWorkflow}" "strict `qmllint`")
    assert_file_contains("${qtWorkflow}" "Controls style")
    assert_file_contains("${qtWorkflow}" "binding loops")
    assert_file_contains("${qtWorkflow}" "timer-only")
    assert_file_contains("${qtWorkflow}" "QT_RESOURCE_ALIAS")
    assert_file_contains("${qtWorkflow}" "QT_QML_OUTPUT_DIRECTORY")
    assert_file_contains("${qtWorkflow}" "RUNTIME_OUTPUT_DIRECTORY")
endforeach()

foreach(verificationWorkflow IN ITEMS
    .agents/skills/source-command-implement/SKILL.md
    .agents/skills/source-command-test/SKILL.md
    .agents/skills/source-command-release/SKILL.md
    .claude/commands/implement.md
    .claude/commands/test.md
    .claude/commands/release.md
)
    assert_file_contains("${verificationWorkflow}" "full default")
    assert_file_contains("${verificationWorkflow}" "NOT VERIFIED")
    assert_file_contains("${verificationWorkflow}" "qmldir")
    assert_file_contains("${verificationWorkflow}" ".qmltypes")
endforeach()

foreach(visualWorkflow IN ITEMS
    .agents/skills/source-command-design-qt-quick-ui/SKILL.md
    .agents/skills/source-command-test/SKILL.md
    .agents/skills/source-command-release/SKILL.md
    .claude/commands/design-qt-quick-ui.md
    .claude/commands/test.md
    .claude/commands/release.md
)
    assert_file_contains("${visualWorkflow}" "acceptance matrix")
endforeach()

foreach(ciText IN ITEMS
    "macOS Clang project modules"
    "Fedora 43 GCC project modules"
    "Ubuntu 25.10 GCC project modules"
    "scripts/verify-linux.sh"
    "--no-tests=error"
)
    assert_file_contains(".github/workflows/ci.yml" "${ciText}")
endforeach()

foreach(readmeText IN ITEMS
    "AIMCPP_PROJECT_MODULES=ON"
    "AIMCPP_STANDARD_LIBRARY=HEADERS"
    "global module fragments"
    "Nested `QML_ELEMENT` adapter headers"
    "passing core"
    "unbuilt Qt executable"
    "`NOT VERIFIED`"
    "Explicit layout contracts"
    "Rendered visual acceptance"
    "START PROJECT"
    "What should the project be called?"
    "exact repository commit SHA"
    "Explicit Qt Quick Controls style selection"
    "zero project warnings"
    "fixed timer"
    "Generated QML sources remain project-relative"
    "receive deterministic"
    "same-name `MyApp` Qt integration fixture"
)
    assert_file_contains("README.md" "${readmeText}")
endforeach()

foreach(evalId IN ITEMS
    EVAL-TCH-001
    EVAL-TCH-007
    EVAL-TCH-008
    EVAL-TCH-009
    EVAL-TCH-010
    EVAL-TCH-011
)
    assert_file_contains("evals/toolchains.md" "${evalId}")
endforeach()
assert_file_contains("evals/reflection.md" "EVAL-REF-010")
assert_file_contains("evals/reflection.md" "EVAL-REF-011")
assert_file_contains("evals/reflection.md" "EVAL-REF-012")
assert_file_contains("evals/reflection.md" "EVAL-REF-013")
assert_file_contains("evals/reflection.md" "EVAL-REF-014")
assert_file_contains("evals/reflection.md" "EVAL-REF-015")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-009")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-010")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-011")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-012")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-013")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-014")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-015")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-016")

foreach(evalId IN ITEMS
    EVAL-INI-001
    EVAL-INI-002
    EVAL-INI-003
    EVAL-INI-004
)
    assert_file_contains("evals/project_initiation.md" "${evalId}")
endforeach()

assert_file_contains("CMakeLists.txt" "NAME qt_quick_baseline_integration")

foreach(fixtureText IN ITEMS
    "project(MyApp"
    "FILE_SET CXX_MODULES"
    "CXX_SCAN_FOR_MODULES ON"
    "QT_RESOURCE_ALIAS"
    "QT_QML_OUTPUT_DIRECTORY"
    "RUNTIME_OUTPUT_DIRECTORY"
    "qt_add_qml_module(MyApp"
    "URI MyApp"
    "loadFromModule(QStringLiteral(\"MyApp\"), QStringLiteral(\"Main\"))"
    "MyApp_qmllint_strict"
    "-M MyApp"
    "QT_FATAL_WARNINGS=1"
)
    if(fixtureText MATCHES "loadFromModule")
        assert_file_contains(
            "tests/fixtures/qt_quick_baseline/src/bootstrap/main.cpp"
            "${fixtureText}"
        )
    elseif(fixtureText STREQUAL "QT_FATAL_WARNINGS=1")
        assert_file_contains(
            "tests/fixtures/qt_quick_baseline/CMakeLists.txt"
            "${fixtureText}"
        )
    else()
        assert_file_contains(
            "tests/fixtures/qt_quick_baseline/CMakeLists.txt"
            "${fixtureText}"
        )
    endif()
endforeach()

assert_file_not_contains(
    "tests/fixtures/qt_quick_baseline/CMakeLists.txt"
    "\"\${CMAKE_CURRENT_SOURCE_DIR}/ui/Main.qml\""
)
assert_text_before(
    "tests/fixtures/qt_quick_baseline/CMakeLists.txt"
    "QT_RESOURCE_ALIAS"
    "qt_add_qml_module(MyApp"
)

foreach(integrationText IN ITEMS
    "qml/MyApp/qmldir"
    "qml/MyApp/MyApp.qmltypes"
    "bin/MyApp"
    "foreach(expectedAlias IN ITEMS"
    "Main.qml"
    "leakedUiAliasPosition"
    "Qt baseline full build"
    "Qt baseline strict QML lint"
    "Qt baseline CTest"
)
    assert_file_contains(
        "tests/qt_quick_baseline_integration.cmake"
        "${integrationText}"
    )
endforeach()

foreach(preflightText IN ITEMS
    "aimcpp_reject_final_qml_creatable_types"
    "GUI-021"
    "QML_ELEMENT"
)
    assert_file_contains("cmake/AimcppProjectChecks.cmake" "${preflightText}")
    assert_file_contains("tests/project_checks.cmake" "${preflightText}")
endforeach()

message(STATUS
    "Knowledge contract verified: project initiation, modules, deterministic QML resources, separated outputs, full-product evidence, and visual acceptance remain synchronized."
)
