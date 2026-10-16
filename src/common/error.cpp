#include "common/error.hpp"

#include <cstdlib>
#include <iostream>
#include <string>

namespace common
{

void fatal_impl(const std::string& message)
{
    std::cerr << message << '\n';
    std::exit(EXIT_FAILURE);
}

} // namespace common
