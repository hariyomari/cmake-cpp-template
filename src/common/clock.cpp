#include <chrono>
#include <cstdint>

#include "common/clock.hpp"

namespace common
{

std::uint64_t unix_seconds()
{
    using namespace std::chrono;

    const auto now = system_clock::now();
    const auto elapsed = now.time_since_epoch();
    const auto secs = duration_cast<seconds>(elapsed);

    return static_cast<std::uint64_t>(secs.count());
}

} // namespace common
