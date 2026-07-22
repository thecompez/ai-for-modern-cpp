module;

#include <string_view>

export module my.app.domain;

export namespace my::app::domain {

/**
 * @brief Returns the deterministic fixture status text.
 */
[[nodiscard]] std::string_view statusText() noexcept;

}
