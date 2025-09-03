#include "kernel/types.h"
#include "kernel/riscv.h"
#include "user/user.h"


int main(int argc, char * argv[])
{
    printf("setting ticket for parent process\n");

    int number = atoi(argv[1]);
    int r = settickets(number);
    if(r < 0)
    {
        printf("setticket unsuccessful!\n");
    }else
    {
        printf("setticket successful!\n");
    }

    int val = fork();

    if(val == 0) {
        printf("\nFork successful\n");
        // Child process runs for a while
        for(volatile int i = 0; i < 100000000; i++);
        exit(0);
    }
    else if (val < 0) {
        printf("\nFork unsuccessful\n");
        exit(1);
    }

    // Parent process runs for a while
    for(volatile int i = 0; i < 100000000; i++);
    wait(0);  // Wait for child to finish
    printf("Parent process completed\n");
    exit(0);
}