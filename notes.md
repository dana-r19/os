# Lab 2 notes

## Part 2: Using xv6

1. Three programs xv6 ships with: cat, echo and wc. I ran all three at the xv6 prompt.

2. For the pipe in `ls | grep c` to work, the OS needs processes and a way for them to communicate. The shell starts ls and grep as two separate processes (using fork and exec). The kernel's pipe mechanism then connects the output of ls to the input of grep, so data passes from one process to the other.

3. The xv6 shell works like the Linux shell from Lab 1 for the basics: it runs commands and supports pipes. It is much simpler, because it is a minimal shell without the extras a full Linux shell has.

## Part 3: Reading the source

1. user/cat.c uses these system calls:
   - open(argv[i], O_RDONLY): asks the kernel to open a file for reading and give back a file descriptor.
   - read(fd, buf, sizeof(buf)): asks the kernel to copy data from the open file into the program's buffer.
   - write(1, buf, n): asks the kernel to write n bytes to file descriptor 1 (standard output, the screen).
   - close(fd): asks the kernel to release the file descriptor.
   - exit(0) / exit(1): asks the kernel to end the program and report its status (0 for success, 1 for an error).

2. sys_read is implemented in kernel/sysfile.c, on line 69 (sys_write is on line 83 of the same file).

3. The code in kernel/ is the operating system itself. It runs privileged and handles the scheduler, memory, the file system and the system-call handlers. The code in user/ is the ordinary programs (ls, cat, echo, the shell) that run on top of it and ask the kernel for services through system calls.

## Note on sleep.c

In the xv6 version I cloned, the system call is named `pause`, not `sleep` (user/user.h declares `int pause(int);`). So user/sleep.c calls `pause()`. The program is still named `sleep`.
