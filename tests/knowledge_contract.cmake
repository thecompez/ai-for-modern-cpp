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
    BLD-004
    BLD-005
    BLD-009
    BLD-013
    BLD-014
    BLD-015
    VER-002
    VER-007
    VER-008
    VER-009
    VER-010
    TST-007
    TST-008
    REP-008
    REP-009
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
    BLD-005
    BLD-013
    BLD-014
    BLD-015
    TST-007
    TST-008
    VER-008
    VER-009
    VER-010
    REP-008
    REP-009
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
)
    assert_file_contains("docs/agent/PROJECT_CMAKE_BASELINE.md" "${baselineText}")
endforeach()

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
    "GUI startup smoke"
    "Layout Contract"
    "Alignment And Rhythm Audit"
    "Content Balance And Empty Space"
    "Visual Acceptance Matrix"
    "minimum, standard, and wide"
    "aimcpp_reject_final_qml_creatable_types"
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
)
    assert_file_contains("README.md" "${readmeText}")
endforeach()

foreach(evalId IN ITEMS
    EVAL-TCH-001
    EVAL-TCH-007
    EVAL-TCH-008
)
    assert_file_contains("evals/toolchains.md" "${evalId}")
endforeach()
assert_file_contains("evals/reflection.md" "EVAL-REF-010")
assert_file_contains("evals/reflection.md" "EVAL-REF-011")
assert_file_contains("evals/reflection.md" "EVAL-REF-012")
assert_file_contains("evals/reflection.md" "EVAL-REF-013")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-009")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-010")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-011")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-012")
assert_file_contains("evals/ui_and_syntax.md" "EVAL-UI-013")

foreach(evalId IN ITEMS
    EVAL-INI-001
    EVAL-INI-002
    EVAL-INI-003
    EVAL-INI-004
)
    assert_file_contains("evals/project_initiation.md" "${evalId}")
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
    "Knowledge contract verified: project initiation, project modules, Qt preflight, full-product evidence, and visual acceptance remain synchronized."
)
