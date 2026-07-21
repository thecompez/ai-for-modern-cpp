if(NOT DEFINED AIMCPP_SOURCE_DIR)
    message(FATAL_ERROR "AIMCPP_SOURCE_DIR is required.")
endif()

set(_required_knowledge_files
    AGENTS.md
    README.md
    .github/workflows/ci.yml
    cmake/AimcppImportStd.cmake
    docs/REVIEW.md
    docs/agent/README.md
    docs/agent/ARCHITECTURE.md
    docs/agent/MODULES.md
    docs/agent/NAMING.md
    docs/agent/SYNTAX_AND_STYLE.md
    docs/agent/API_DESIGN.md
    docs/agent/ERRORS_AND_RESOURCES.md
    docs/agent/PLATFORM_BOUNDARIES.md
    docs/agent/QT_QUICK_UI.md
    docs/agent/CMAKE_AND_TOOLCHAINS.md
    docs/agent/TESTING_AND_VERIFICATION.md
    docs/agent/COMMON_FAILURES.md
    docs/agent/PATTERNS.md
    evals/README.md
    evals/implementation.md
    evals/review.md
    evals/toolchains.md
    evals/reflection.md
    evals/ui_and_syntax.md
    scripts/bootstrap-linux-cmake.sh
    scripts/verify-linux.sh
    tests/import_std_metadata.cmake
    .agents/README.md
    .agents/skills/source-command-add-module/SKILL.md
    .agents/skills/source-command-design-qt-quick-ui/SKILL.md
    .agents/skills/source-command-implement/SKILL.md
    .agents/skills/source-command-reflect/SKILL.md
    .agents/skills/source-command-release/SKILL.md
    .agents/skills/source-command-review/SKILL.md
    .agents/skills/source-command-test/SKILL.md
    .claude/commands/add-module.md
    .claude/commands/design-qt-quick-ui.md
    .claude/commands/implement.md
    .claude/commands/reflect.md
    .claude/commands/release.md
    .claude/commands/review.md
    .claude/commands/test.md
)

foreach(_relative_path IN LISTS _required_knowledge_files)
    if(NOT EXISTS "${AIMCPP_SOURCE_DIR}/${_relative_path}")
        message(FATAL_ERROR "Required knowledge file is missing: ${_relative_path}")
    endif()
endforeach()

file(READ "${AIMCPP_SOURCE_DIR}/AGENTS.md" _agent_contract)

set(_required_rule_ids
    KNO-001
    SCP-001
    ARC-001
    MOD-001
    MOD-009
    NAM-001
    NAM-003
    NAM-005
    SYN-001
    SYN-004
    API-001
    ERR-001
    RES-001
    PLT-001
    GUI-001
    GUI-002
    GUI-004
    GUI-012
    GUI-015
    GUI-016
    BLD-001
    BLD-010
    BLD-011
    BLD-012
    TST-001
    VER-001
    VER-007
    DOC-001
    DOC-008
    SEC-001
    CHG-001
    REP-001
    REP-007
)

foreach(_rule_id IN LISTS _required_rule_ids)
    string(FIND "${_agent_contract}" "${_rule_id}" _rule_position)
    if(_rule_position EQUAL -1)
        message(FATAL_ERROR "Canonical rule is missing: ${_rule_id}")
    endif()
endforeach()

file(READ "${AIMCPP_SOURCE_DIR}/docs/REVIEW.md" _review_contract)
foreach(_rule_id IN ITEMS
    KNO-005
    DOC-008
    MOD-009
    NAM-003
    NAM-005
    SYN-004
    GUI-001
    GUI-004
    GUI-012
    GUI-015
    GUI-016
    BLD-010
    BLD-011
    BLD-012
    VER-007
    REP-007
)
    string(FIND "${_review_contract}" "${_rule_id}" _review_rule_position)
    if(_review_rule_position EQUAL -1)
        message(FATAL_ERROR "Review contract does not cover: ${_rule_id}")
    endif()
endforeach()

file(READ "${AIMCPP_SOURCE_DIR}/.github/workflows/ci.yml" _ci_workflow)
string(
    REGEX MATCHALL
    "bash scripts/bootstrap-linux-cmake[.]sh"
    _linux_cmake_bootstrap_steps
    "${_ci_workflow}"
)
list(LENGTH _linux_cmake_bootstrap_steps _linux_cmake_bootstrap_count)
if(_linux_cmake_bootstrap_count LESS 2)
    message(FATAL_ERROR
        "Every Linux GCC CI job must bootstrap the supported repository-local CMake."
    )
endif()

set(_domain_neutral_knowledge_files
    README.md
    docs/agent/NAMING.md
    docs/agent/SYNTAX_AND_STYLE.md
    docs/agent/QT_QUICK_UI.md
    docs/agent/PATTERNS.md
)

foreach(_relative_path IN LISTS _domain_neutral_knowledge_files)
    file(READ "${AIMCPP_SOURCE_DIR}/${_relative_path}" _neutral_knowledge_content)
    string(TOLOWER "${_neutral_knowledge_content}" _neutral_knowledge_lower)
    string(FIND "${_neutral_knowledge_lower}" "calculator" _specific_domain_position)
    if(NOT _specific_domain_position EQUAL -1)
        message(FATAL_ERROR
            "General-purpose knowledge uses a scenario-specific calculator name: ${_relative_path}"
        )
    endif()
endforeach()

set(_executable_proof_sources
    src/main.cpp
    src/modern_cpp_agent/modern_cpp_agent.cppm
    src/modern_cpp_agent/modern_cpp_agent.cpp
    tests/core_tests.cpp
)

foreach(_relative_path IN LISTS _executable_proof_sources)
    file(READ "${AIMCPP_SOURCE_DIR}/${_relative_path}" _source_content)
    string(FIND "${_source_content}" "import std;" _import_std_position)
    if(_import_std_position EQUAL -1)
        message(FATAL_ERROR "Executable proof stopped using import std: ${_relative_path}")
    endif()

    string(
        REGEX MATCH
        "case[ \t\r\n]+([A-Za-z][A-Za-z0-9]*::)*[a-z][A-Za-z0-9_]*[ \t\r\n]*:"
        _lowercase_enum_case
        "${_source_content}"
    )
    if(_lowercase_enum_case)
        message(FATAL_ERROR
            "Executable proof contains a lowercase enum case in ${_relative_path}: ${_lowercase_enum_case}"
        )
    endif()

    string(
        REGEX MATCH
        "[A-Za-z][A-Za-z0-9]*_[ \t]*(\\{|=|;)"
        _trailing_underscore_identifier
        "${_source_content}"
    )
    if(_trailing_underscore_identifier)
        message(FATAL_ERROR
            "Executable proof contains a trailing-underscore identifier in ${_relative_path}: ${_trailing_underscore_identifier}"
        )
    endif()
endforeach()

file(READ "${AIMCPP_SOURCE_DIR}/docs/agent/SYNTAX_AND_STYLE.md" _syntax_guide)
foreach(_required_shape IN ITEMS
    "case ErrorCode::EmptyExpression:"
    "m_expressionText"
    "mymember_"
)
    string(FIND "${_syntax_guide}" "${_required_shape}" _syntax_shape_position)
    if(_syntax_shape_position EQUAL -1)
        message(FATAL_ERROR "Syntax guide is missing a required naming shape: ${_required_shape}")
    endif()
endforeach()

file(READ "${AIMCPP_SOURCE_DIR}/docs/agent/QT_QUICK_UI.md" _qt_quick_guide)
foreach(_required_shape IN ITEMS
    "Qt Quick Controls"
    "qt_add_qml_module"
    "Qt6::Widgets"
    "keyboard"
    "accessibility"
    "user-facing interactive application"
    "CLI-only"
    "secondary adapter"
)
    string(FIND "${_qt_quick_guide}" "${_required_shape}" _qt_shape_position)
    if(_qt_shape_position EQUAL -1)
        message(FATAL_ERROR "Qt Quick guide is missing required guidance: ${_required_shape}")
    endif()
endforeach()

file(READ "${AIMCPP_SOURCE_DIR}/docs/agent/PATTERNS.md" _pattern_guide)
foreach(_required_shape IN ITEMS
    "Qt Quick primary interface"
    "optional CLI adapter"
    "GUI-015"
    "GUI-016"
)
    string(FIND "${_pattern_guide}" "${_required_shape}" _pattern_shape_position)
    if(_pattern_shape_position EQUAL -1)
        message(FATAL_ERROR
            "Pattern guide is missing interaction-surface guidance: ${_required_shape}"
        )
    endif()
endforeach()

file(READ "${AIMCPP_SOURCE_DIR}/evals/ui_and_syntax.md" _ui_eval_suite)
foreach(_required_shape IN ITEMS
    "EVAL-UI-005"
    "GUI-015"
    "GUI-016"
)
    string(FIND "${_ui_eval_suite}" "${_required_shape}" _ui_eval_position)
    if(_ui_eval_position EQUAL -1)
        message(FATAL_ERROR
            "UI eval suite is missing interaction-surface coverage: ${_required_shape}"
        )
    endif()
endforeach()

file(READ
    "${AIMCPP_SOURCE_DIR}/.agents/skills/source-command-implement/SKILL.md"
    _implement_skill
)
string(FIND "${_implement_skill}" "GUI-015" _implement_surface_rule_position)
if(_implement_surface_rule_position EQUAL -1)
    message(FATAL_ERROR
        "Implementation workflow does not route unspecified interactive applications through GUI-015."
    )
endif()

file(READ "${AIMCPP_SOURCE_DIR}/src/main.cpp" _executable_entry_point)
string(FIND "${_executable_entry_point}" "Agent Template" _legacy_purpose_position)
if(NOT _legacy_purpose_position EQUAL -1)
    message(FATAL_ERROR "Executable proof regressed to the obsolete template purpose.")
endif()

file(GLOB_RECURSE _legacy_headers "${AIMCPP_SOURCE_DIR}/src/*.h")
if(_legacy_headers)
    message(FATAL_ERROR "Legacy project headers are forbidden: ${_legacy_headers}")
endif()

file(READ "${AIMCPP_SOURCE_DIR}/README.md" _readme)
foreach(_required_phrase IN ITEMS
    "executable knowledge base"
    "docs/agent/README.md"
    "evals/README.md"
    "AIMCPP_IMPORT_STD_REQUIRED=ON"
    "source-command-design-qt-quick-ui"
    "Interaction Surface Default"
    "docs/agent/SYNTAX_AND_STYLE.md"
    "scripts/bootstrap-linux-cmake.sh"
    "scripts/verify-linux.sh"
)
    string(FIND "${_readme}" "${_required_phrase}" _phrase_position)
    if(_phrase_position EQUAL -1)
        message(FATAL_ERROR "README knowledge map is missing: ${_required_phrase}")
    endif()
endforeach()

message(STATUS "Agent knowledge contract verified.")
