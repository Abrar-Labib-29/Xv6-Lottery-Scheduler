# 🎰 Xv6-Lottery-Scheduler

A modified xv6 operating system implementing **Lottery Scheduling Algorithm** - a proportional-share CPU scheduler that uses randomized selection based on process tickets.

[![Built with xv6](https://img.shields.io/badge/Built%20with-xv6-blue.svg)](https://github.com/mit-pdos/xv6-riscv)
[![RISC-V](https://img.shields.io/badge/Architecture-RISC--V-green.svg)](https://riscv.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 🎯 Overview

This project replaces xv6's default round-robin scheduler with a **lottery scheduler** that provides proportional fairness based on process tickets. Processes with more tickets have a higher probability of being selected to run, creating a fair share scheduling system.

### Key Features

- 🎲 **Lottery-based CPU scheduling** - Random selection weighted by process tickets
- 🎫 **Dynamic ticket management** - Processes can adjust their CPU share at runtime
- 📊 **Process introspection** - View scheduling statistics and ticket distribution
- 🔄 **Automatic ticket reset** - Prevents starvation when all tickets are exhausted
- 👥 **Fork inheritance** - Child processes inherit parent's ticket allocation

## 🚀 What's New

### System Calls Added

| System Call | Description | Usage |
|-------------|-------------|-------|
| `settickets(int n)` | Set process tickets (CPU share) | `settickets(10)` gives 10x more CPU time |
| `getpinfo(struct pstat* ps)` | Get scheduling info for all processes | Monitor ticket usage and time slices |

### Process Tracking

Each process now maintains:
- **`tickets_original`** - Base ticket allocation (default: 1)
- **`tickets_current`** - Remaining tickets for current round
- **`time_slices`** - Total times the process has been scheduled

## 🛠️ Implementation Details

### Lottery Algorithm

1. **Ticket Counting**: Sum all `tickets_current` from RUNNABLE processes
2. **Random Draw**: Generate random number in range [0, total_tickets)
3. **Winner Selection**: Walk process table until cumulative tickets exceed random number
4. **Accounting**: Increment `time_slices`, decrement `tickets_current`
5. **Reset Logic**: When all processes have `tickets_current == 0`, reset from `tickets_original`

### Code Structure

```
kernel/
├── proc.h          # Added lottery fields to struct proc
├── proc.c          # Lottery scheduler implementation + syscalls
├── syscall.h       # System call numbers (22, 23)
├── syscall.c       # System call registration
└── pstat.h         # Process statistics structure
```

## 🏗️ Building and Running

### Prerequisites
- RISC-V GNU toolchain
- QEMU RISC-V system emulator

### Build Instructions

```bash
# Clone the repository
git clone https://github.com/Abrar-Labib-29/Xv6-Lottery-Scheduler.git
cd xv6-lottery-scheduler

# Build xv6
make

# Run in QEMU
make qemu
```

## 🧪 Testing the Scheduler

### Basic Fairness Test

```c
// Create multiple CPU-bound processes with default tickets (1 each)
// Over time, they should receive roughly equal CPU time
```

### Proportional Fairness Test

```c
#include "kernel/types.h"
#include "user/user.h"
#include "kernel/pstat.h"

int main() {
    // Give this process 10 tickets
    settickets(10);
    
    // CPU-intensive work
    for(int i = 0; i < 1000000; i++) {
        // busy work
    }
    
    // Check scheduling statistics
    struct pstat ps;
    getpinfo(&ps);
    
    // This process should have ~10x more time_slices than 1-ticket processes
    return 0;
}
```

### Monitoring System State

```c
struct pstat ps;
if (getpinfo(&ps) == 0) {
    for (int i = 0; i < NPROC; i++) {
        if (ps.inuse[i]) {
            printf("PID: %d, Tickets: %d/%d, Slices: %d\n", 
                   ps.pid[i], ps.tickets_current[i], 
                   ps.tickets_original[i], ps.time_slices[i]);
        }
    }
}
```

## 🎨 Design Decisions

### Randomness
- Implemented simple Linear Congruential Generator (LCG) in kernel space
- Sufficient randomness for fair scheduling distribution
- Deterministic for reproducible testing

### Ticket Reset Policy
- When all RUNNABLE processes have `tickets_current == 0`
- Reset `tickets_current = tickets_original` for all processes
- Prevents permanent starvation while maintaining proportionality

### Fork Behavior
- Child inherits parent's `tickets_original` and `tickets_current`
- Child's `time_slices` starts at 0
- Maintains ticket accounting across process creation

## 📈 Performance Characteristics

- **Fairness**: Processes receive CPU time proportional to their tickets
- **Overhead**: Minimal - O(n) scheduler loop where n = number of processes
- **Starvation**: Prevented by automatic ticket reset mechanism
- **Responsiveness**: Maintains good interactive performance with proper ticket allocation

## 🔒 Concurrency Safety

- All ticket operations protected by process locks (`p->lock`)
- Safe concurrent access to process table during scheduling
- Atomic updates to prevent race conditions

## 🤝 Contributing

Contributions are welcome! Areas for improvement:

- [ ] Multi-level lottery scheduling
- [ ] Per-CPU lottery pools
- [ ] Better randomness sources
- [ ] Comprehensive test suite
- [ ] Performance benchmarking tools

## 📚 Educational Value

This implementation demonstrates:
- **Operating Systems**: CPU scheduling algorithms
- **Systems Programming**: Kernel development and system calls
- **Concurrency**: Lock-based synchronization
- **Randomization**: Pseudo-random number generation in kernel space

## 📖 References

- [xv6: a simple, Unix-like teaching operating system](https://pdos.csail.mit.edu/6.828/2023/xv6.html)
- [Lottery Scheduling: Flexible Proportional-Share Resource Management](https://www.waldspurger.org/carl/papers/lottery-sosp94.pdf)
- Original xv6 source: [mit-pdos/xv6-riscv](https://github.com/mit-pdos/xv6-riscv)

## 📄 License

This project is licensed under the MIT License.

---

> Built as part of my "Operating Systems" course assignment. Demonstrates lottery scheduling concepts in a real kernel environment. For any queries, please reach me at - abrar.labib2829@gmail.com
