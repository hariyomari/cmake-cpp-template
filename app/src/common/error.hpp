#pragma once

#include <format>
#include <string>
#include <utility>

namespace common
{

[[noreturn]] void fatal_impl(const std::string& message);

template <typename... Args>
[[noreturn]] void fatal(std::format_string<Args...> fmt, Args&&... args)
{
    fatal_impl(std::format(fmt, std::forward<Args>(args)...));
}

} // namespace common
