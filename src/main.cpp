import std;
import modern.cpp.agent;

namespace {

/**
 * @brief Demonstrates a small compile-time value object.
 */
struct ShowcaseSection final {
    std::string title;
    std::string body;

    /**
     * @brief Renders the section into a terminal-friendly block.
     */
    [[nodiscard]] auto toText() const -> std::string
    {
        return std::format("## {}\n{}\n", title, body);
    }
};

/**
 * @brief Renders any object that follows the TextRenderable contract.
 */
template <modern::cpp::agent::TextRenderable T>
auto printSection(const T& section) -> void
{
    std::println("{}", section.toText());
}

/**
 * @brief Converts a verification phase list into a visual pipeline.
 */
[[nodiscard]] auto renderPipeline(
    std::span<const modern::cpp::agent::VerificationPhase> phases
) -> std::string
{
    auto output = std::string {};
    auto index = std::size_t {0};

    for (const auto phase : phases) {
        if (index > 0) {
            output += " -> ";
        }

        output += modern::cpp::agent::toString(phase);
        ++index;
    }

    return output;
}

/**
 * @brief Demonstrates constexpr computation in a compact and readable form.
 */
[[nodiscard]] consteval auto minimumAcceptedMajorStandard() -> int
{
    return 20;
}

}

auto main() -> int
{
    using namespace modern::cpp::agent;

    const RepositoryName repositoryName{"ai-for-modern-cpp"};
    constexpr auto minimumStandard = minimumAcceptedMajorStandard();

    static_assert(minimumStandard >= 20);
    static_assert(preferredCompiler().contains("Clang"));

    const auto selectedStandard = validateMinimumStandard(StandardLevel::Cpp26);

    if (!selectedStandard) {
        std::println("Invalid standard policy: {}", selectedStandard.error());
        return 1;
    }

    const auto rules = makeDefaultRules();
    const auto pipeline = makeVerificationPipeline();

    const auto now = std::chrono::system_clock::now();

    printSection(
        ShowcaseSection {
            .title = "Modern C++ Agent Knowledge Reference",
            .body = makePolicySummary(repositoryName, *selectedStandard)
        }
    );

    printSection(
        ShowcaseSection {
            .title = "Toolchain",
            .body = std::format(
                "Preferred compiler: {}\nMinimum language family: C++{}\nGenerated at: {:%Y-%m-%d %H:%M:%S} UTC",
                preferredCompiler(),
                minimumStandard,
                std::chrono::floor<std::chrono::seconds>(now)
            )
        }
    );

    printSection(
        ShowcaseSection {
            .title = "Verification Pipeline",
            .body = renderPipeline(pipeline)
        }
    );

    printSection(
        ShowcaseSection {
            .title = "Agent Rules",
            .body = renderRules(rules)
        }
    );

    if (const auto rule = findRuleByTitle(rules, "RAII")) {
        std::println("Highlighted rule: {} — {}", rule->title, rule->description);
    }

    return 0;
}
