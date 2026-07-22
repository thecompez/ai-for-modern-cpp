module;

#include <string_view>

module my.app.domain;

namespace my::app::domain {

std::string_view statusText() noexcept
{
    return "ready";
}

}
