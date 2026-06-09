#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/utils.h"

#define ERRNO_BUF_SIZE 1024

void exit_success(void) { exit(EXIT_SUCCESS); }
void exit_failure(void) { exit(EXIT_FAILURE); }

int errno_str(char *out_buf, size_t buf_size)
{
    if (out_buf == NULL || buf_size == 0)
    {
        return -1;
    }

    char *err = strerror(errno);
    if (err == NULL)
    {
        return -1;
    }

    snprintf(out_buf, buf_size, "%s", err);
    return 0;
}

void fatal(const char *m)
{
    if (m != NULL)
    {
        fprintf(stderr, "%s\n", m);
    }

    char buf[ERRNO_BUF_SIZE];
    if (errno_str(buf, sizeof(buf)) == -1)
    {
        fprintf(stderr, "Failed to get errno\n");
    }
    else
    {
        fprintf(stderr, "errno: %s\n\n", buf);
    }

    exit_failure();
}

void fatal_fmt(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    fprintf(stderr, "\n");
    vfprintf(stderr, fmt, args);
    va_end(args);

    fatal(NULL);
}
