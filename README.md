# Xv6-Lottery-Scheduler
Xv6 operating system, modified with a lottery scheduler replacing round-robin. Processes have tickets influencing CPU share; scheduler selects processes by weighted random draw. Includes settickets and getpinfo syscalls for controlling and monitoring scheduling. Features ticket reset, fork inheritance, and kernel RNG for fairness.
