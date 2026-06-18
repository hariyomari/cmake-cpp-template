#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include "common/utils.h"
#include "macros.h"

void cleanup(void) { }

void handle_sigint(int sig)
{
    UNUSED(sig);
    cleanup();
    exit_success();
}

int main(int argc, const char** argv)
{
    UNUSED(argc + argv);

    atexit(exit_success);
    signal(SIGINT, handle_sigint);

    printf("Hello, %s\n", "World!");

    return EXIT_SUCCESS;
}
