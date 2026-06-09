#pragma once

#define NUM(a) (sizeof(a) / sizeof(*a))
#define UNUSED(...) (void)(__VA_ARGS__)

// string length (+1 for null-terminator '\0')
#define STRLENNT(n) (n + 1)
