#include <string_view>

import my.app.domain;

int main()
{
    return my::app::domain::statusText() == std::string_view {"ready"} ? 0 : 1;
}
