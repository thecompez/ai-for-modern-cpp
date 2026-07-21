module;

#if !AIMCPP_USE_IMPORT_STD
#include <algorithm>
#include <expected>
#include <format>
#include <optional>
#include <span>
#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>
#include <vector>
#endif

module modern.cpp.agent;

#if AIMCPP_USE_IMPORT_STD
import std;
#endif

namespace modern::cpp::agent {

auto toString(StandardLevel level) noexcept -> std::string_view
{
    using enum StandardLevel;

    switch (level) {
    case Cpp20:
        return "C++20";
    case Cpp23:
        return "C++23";
    case Cpp26:
        return "C++26";
    }

    std::unreachable();
}

auto toString(VerificationPhase phase) noexcept -> std::string_view
{
    using enum VerificationPhase;

    switch (phase) {
    case Configure:
        return "Configure";
    case Build:
        return "Build";
    case Test:
        return "Test";
    case Review:
        return "Review";
    }

    std::unreachable();
}

RepositoryName::RepositoryName(std::string value)
    : m_value(std::move(value))
{
    if (m_value.empty()) {
        throw std::invalid_argument{"Repository name must not be empty."};
    }
}

auto RepositoryName::value() const noexcept -> std::string_view
{
    return m_value;
}

auto makePolicySummary(
    const RepositoryName& repositoryName,
    StandardLevel standardLevel
) -> std::string
{
    return std::format(
        "{} is an executable {}+ knowledge reference with modules, cppm/cpp separation, concepts, tests, and AI loop verification.",
        repositoryName.value(),
        toString(standardLevel)
    );
}

auto makeVerificationPipeline() -> std::vector<VerificationPhase>
{
    return {
        VerificationPhase::Configure,
        VerificationPhase::Build,
        VerificationPhase::Test,
        VerificationPhase::Review
    };
}

auto makeDefaultRules() -> std::vector<AgentRule>
{
    return {
        {
            .title = "Modules first",
            .description = "Use .cppm for declarations and .cpp for implementations."
        },
        {
            .title = "Compile-time contracts",
            .description = "Use concepts, static_assert, constexpr, consteval, and constinit when they improve correctness."
        },
        {
            .title = "RAII ownership",
            .description = "Keep low-level resource handling isolated behind deterministic cleanup types."
        },
        {
            .title = "Honest verification",
            .description = "Never claim build or test success unless the commands actually passed."
        }
    };
}

auto findRuleByTitle(
    std::span<const AgentRule> rules,
    std::string_view titlePart
) -> std::optional<AgentRule>
{
    const auto found = std::ranges::find_if(
        rules,
        [titlePart](const AgentRule& rule) {
            return rule.title.contains(titlePart);
        }
    );

    if (found == rules.end()) {
        return std::nullopt;
    }

    return *found;
}

auto renderRules(std::span<const AgentRule> rules) -> std::string
{
    auto output = std::string {};
    auto index = std::size_t {1};

    for (const auto& rule : rules) {
        output += std::format(
            "{}. {} — {}",
            index,
            rule.title,
            rule.description
        );

        output += '\n';
        ++index;
    }

    return output;
}

auto validateMinimumStandard(
    StandardLevel level
) -> std::expected<StandardLevel, std::string>
{
    using enum StandardLevel;

    if (level == Cpp20 || level == Cpp23 || level == Cpp26) {
        return level;
    }

    return std::unexpected{"Unsupported C++ standard level."};
}

}
