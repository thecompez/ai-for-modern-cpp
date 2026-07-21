if(NOT DEFINED AIMCPP_SOURCE_DIR)
    message(FATAL_ERROR "AIMCPP_SOURCE_DIR is required.")
endif()

set(_required_knowledge_files
    AGENTS.md
    README.md
    docs/REVIEW.md
    docs/agent/README.md
    docs/agent/ARCHITECTURE.md
    docs/agent/MODULES.md
    docs/agent/NAMING.md
    docs/agent/API_DESIGN.md
    docs/agent/ERRORS_AND_RESOURCES.md
    docs/agent/PLATFORM_BOUNDARIES.md
    docs/agent/CMAKE_AND_TOOLCHAINS.md
    docs/agent/TESTING_AND_VERIFICATION.md
    docs/agent/COMMON_FAILURES.md
    docs/agent/PATTERNS.md
    evals/README.md
    evals/implementation.md
    evals/review.md
    evals/toolchains.md
    evals/reflection.md
    .agents/README.md
    .agents/skills/source-command-add-module/SKILL.md
    .agents/skills/source-command-implement/SKILL.md
    .agents/skills/source-command-reflect/SKILL.md
    .agents/skills/source-command-release/SKILL.md
    .agents/skills/source-command-review/SKILL.md
    .agents/skills/source-command-test/SKILL.md
    .claude/commands/add-module.md
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
    API-001
    ERR-001
    RES-001
    PLT-001
    BLD-001
    TST-001
    VER-001
    VER-007
    DOC-001
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
foreach(_rule_id IN ITEMS KNO-005 MOD-009 VER-007 REP-007)
    string(FIND "${_review_contract}" "${_rule_id}" _review_rule_position)
    if(_review_rule_position EQUAL -1)
        message(FATAL_ERROR "Review contract does not cover: ${_rule_id}")
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
endforeach()

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
)
    string(FIND "${_readme}" "${_required_phrase}" _phrase_position)
    if(_phrase_position EQUAL -1)
        message(FATAL_ERROR "README knowledge map is missing: ${_required_phrase}")
    endif()
endforeach()

message(STATUS "Agent knowledge contract verified.")
