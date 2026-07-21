module;

#if !AIMCPP_USE_IMPORT_STD
#include <concepts>
#include <expected>
#include <optional>
#include <ostream>
#include <span>
#include <string>
#include <string_view>
#include <vector>
#endif

export module modern.cpp.agent;

#if AIMCPP_USE_IMPORT_STD
import std;
#endif

export namespace modern::cpp::agent {

/**
 * @brief Describes the minimum modern C++ standard policy for a repository.
 */
enum class StandardLevel {
    Cpp20,
    Cpp23,
    Cpp26
};

/**
 * @brief Describes a project verification phase.
 */
enum class VerificationPhase {
    Configure,
    Build,
    Test,
    Review
};

/**
 * @brief Converts a standard level into a stable display string.
 */
[[nodiscard]] auto toString(StandardLevel level) noexcept -> std::string_view;

/**
 * @brief Converts a verification phase into a stable display string.
 */
[[nodiscard]] auto toString(VerificationPhase phase) noexcept -> std::string_view;

/**
 * @brief Represents a validated repository name.
 */
class RepositoryName final {
public:
    /**
     * @brief Creates a repository name from a non-empty string.
     *
     * @throws std::invalid_argument when the name is empty.
     */
    explicit RepositoryName(std::string value);

    /**
     * @brief Returns the stored repository name.
     */
    [[nodiscard]] auto value() const noexcept -> std::string_view;

private:
    std::string m_value;
};

/**
 * @brief Represents a single AI-agent rule that can be printed in a report.
 */
struct AgentRule final {
    std::string title;
    std::string description;
};

/**
 * @brief Defines a compile-time contract for stream-insertable adapter values.
 */
template <typename T>
concept Printable =
    requires(std::ostream& output, const T& value) {
        { output << value } -> std::same_as<std::ostream&>;
    };

/**
 * @brief Defines a compile-time contract for values that can be rendered as text.
 */
template <typename T>
concept TextRenderable =
    requires(const T& value) {
        { value.toText() } -> std::convertible_to<std::string>;
    };

/**
 * @brief Creates a short agent policy summary for a repository.
 */
[[nodiscard]] auto makePolicySummary(
    const RepositoryName& repositoryName,
    StandardLevel standardLevel
) -> std::string;

/**
 * @brief Creates the recommended verification pipeline for AI-generated changes.
 */
[[nodiscard]] auto makeVerificationPipeline() -> std::vector<VerificationPhase>;

/**
 * @brief Creates a default set of modern C++ agent rules.
 */
[[nodiscard]] auto makeDefaultRules() -> std::vector<AgentRule>;

/**
 * @brief Finds the first rule whose title contains the requested text.
 */
[[nodiscard]] auto findRuleByTitle(
    std::span<const AgentRule> rules,
    std::string_view titlePart
) -> std::optional<AgentRule>;

/**
 * @brief Renders a collection of rules into a clean multi-line report.
 */
[[nodiscard]] auto renderRules(std::span<const AgentRule> rules) -> std::string;

/**
 * @brief Validates that the requested standard level is acceptable.
 */
[[nodiscard]] auto validateMinimumStandard(
    StandardLevel level
) -> std::expected<StandardLevel, std::string>;

/**
 * @brief Returns the preferred compiler family and minimum version for this reference.
 */
[[nodiscard]] consteval auto preferredCompiler() -> std::string_view
{
    return "Clang 22+";
}

}
