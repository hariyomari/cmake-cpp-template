#include <stdint.h>
#include <time.h>

#include "common/time.h"

uint64_t get_current_unix_seconds(void)
{
    struct timespec ts;

    if (timespec_get(&ts, TIME_UTC) == 0)
    {
        return 0;
    }

    return (uint64_t)ts.tv_sec;
}
