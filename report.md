# Lab 17 – Threads share memory, and race

Dana Romanov, FAF-241. Runs on Ubuntu (2 CPUs), gcc -Wall -Wextra -pthread.

**1. Thread 2 prints a non-zero counter at the start. What does that prove?**
In runs 1 and 4 thread 2 printed 1000000, and in run 2 it printed 980870. Only thread 1 writes before that, so the two threads read and write the same variable: they share the same memory (one address space). Thread 2 printed 0 in runs 3 and 5 because it started before thread 1 had added anything.

**2. Why is the final counter less than 2000000, and different each run?**
counter++ is three steps: read counter into a register, add 1, write it back. If both threads read the same value (5), both add 1 and both write 6, two additions give one, and an update is lost. The overlap depends on the timing, which is different every run. In runs 1 and 4 the threads did not overlap and the result was exact (2000000); in runs 2 and 3 it was 1981663 and 1425635.

**3. Which single idea would stop the lost updates?**
Make read, add and write indivisible with a lock (a mutex), so that only one thread at a time is in the middle of counter++.

Four threads (fire4): 3 of 5 runs lost updates, the largest loss was 1520265 (counter 2479735). With two threads, 2 of 5 runs lost updates and the largest loss was 574365. The loss gets bigger with more threads.
