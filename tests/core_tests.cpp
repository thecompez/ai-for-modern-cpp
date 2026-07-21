import std;
import modern.cpp.agent;

namespace {

auto require(bool condition, std::string_view message) -> void
{
    if (!condition) {
        throw std::runtime_error{std::string{message}};
    }
}

auto testStandardToString() -> void
{
    require(
        modern::cpp::agent::toString(modern::cpp::agent::StandardLevel::Cpp20) == "C++20",
        "C++20 label mismatch."
    );

    require(
        modern::cpp::agent::toString(modern::cpp::agent::StandardLevel::Cpp23) == "C++23",
        "C++23 label mismatch."
    );

    require(
        modern::cpp::agent::toString(modern::cpp::agent::StandardLevel::Cpp26) == "C++26",
        "C++26 label mismatch."
    );
}

auto testRepositoryNameValidation() -> void
{
    const modern::cpp::agent::RepositoryName name{"sample"};
    require(name.value() == "sample", "RepositoryName value mismatch.");

    auto threw = false;

    try {
        const modern::cpp::agent::RepositoryName invalid{""};
        std::ignore = invalid;
    } catch (const std::invalid_argument&) {
        threw = true;
    }

    require(threw, "RepositoryName must reject empty names.");
}

auto testPolicySummary() -> void
{
    const modern::cpp::agent::RepositoryName name{"sample"};

    const auto summary = modern::cpp::agent::makePolicySummary(
        name,
        modern::cpp::agent::StandardLevel::Cpp26
    );

    require(summary.contains("sample"), "Summary must contain repository name.");
    require(summary.contains("C++26"), "Summary must contain standard level.");
    require(summary.contains("knowledge reference"), "Summary must describe the repository purpose.");
    require(summary.contains("modules"), "Summary must mention modules.");
}

auto testRules() -> void
{
    const auto rules = modern::cpp::agent::makeDefaultRules();

    require(!rules.empty(), "Default rules must not be empty.");

    const auto rendered = modern::cpp::agent::renderRules(rules);

    require(rendered.contains("Modules first"), "Rendered rules must mention modules.");
    require(rendered.contains("Honest verification"), "Rendered rules must mention verification.");

    const auto found = modern::cpp::agent::findRuleByTitle(rules, "RAII");

    require(found.has_value(), "RAII rule must exist.");
}

auto testVerificationPipeline() -> void
{
    const auto pipeline = modern::cpp::agent::makeVerificationPipeline();

    require(pipeline.size() == 4, "Verification pipeline must contain four phases.");

    require(
        pipeline.front() == modern::cpp::agent::VerificationPhase::Configure,
        "Pipeline must start with configure."
    );

    require(
        pipeline.back() == modern::cpp::agent::VerificationPhase::Review,
        "Pipeline must end with review."
    );
}

auto testStandardValidation() -> void
{
    const auto validated = modern::cpp::agent::validateMinimumStandard(
        modern::cpp::agent::StandardLevel::Cpp26
    );

    require(validated.has_value(), "C++26 must be accepted.");
}

}

auto main() -> int
{
    try {
        testStandardToString();
        testRepositoryNameValidation();
        testPolicySummary();
        testRules();
        testVerificationPipeline();
        testStandardValidation();
    } catch (const std::exception& error) {
        std::println("Test failure: {}", error.what());
        return 1;
    }

    std::println("All tests passed.");
    return 0;
}
