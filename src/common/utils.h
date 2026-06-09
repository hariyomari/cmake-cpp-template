#pragma once

#include <stddef.h>

void exit_success(void);
void exit_failure(void);

int errno_str(char *out_buf, size_t buf_size);

void fatal_fmt(const char *fmt, ...);
void fatal(const char *m);
