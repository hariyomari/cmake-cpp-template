#include "common/error.hpp"

#include <cstdio>
#include <cstdlib>
#include <string>

namespace common
{

void fatal_impl(const std::string& message)
{
    std::fprintf(stderr, "%s\n", message.c_str());
    std::exit(EXIT_FAILURE);
}

} // namespace common
