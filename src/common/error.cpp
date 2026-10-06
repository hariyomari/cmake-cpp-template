#include <cstdlib>
#include <iostream>
#include <string>

#include "common/error.hpp"

namespace common
{

void fatal_impl(const std::string& message)
{
    std::cerr << message << '\n';
    std::exit(EXIT_FAILURE);
}

} // namespace common
