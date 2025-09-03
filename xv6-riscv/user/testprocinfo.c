#include "kernel/types.h"
#include "user/user.h"
#include "kernel/stat.h"
#include "kernel/pstat.h"
#include "kernel/param.h"


int main(int argc, char *argv[])
{
    struct pstat pst;
    int r = getpinfo(&pst);
    if(r < 0)
    {
        printf("Something went wrong!\n");
        return 0;
    }
    printf("\nPID\tIn Use\tOriginal Tickets\tCurrent Tickets\t\tTime Slices\n");
    for (int i = 0; i < NPROC; i++)
    {
        if (pst.inuse[i] == 1)
        {
            printf("%d\t%d\t%d\t\t\t%d\t\t\t%d\n",pst.pid[i], pst.inuse[i], pst.tickets_original[i], pst.tickets_current[i], pst.time_slices[i]);
        }
    }
    return 0;
}