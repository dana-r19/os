**MINISTRY OF EDUCATION AND RESEARCH OF THE REPUBLIC OF MOLDOVA**
**TECHNICAL UNIVERSITY OF MOLDOVA**
**Faculty of Computers, Informatics and Microelectronics**
**Study programme: [your programme]**

&nbsp;

# REPORT

## Laboratory Work No. 1

**Discipline:** Operating Systems
**Topic:** The OS as a Resource Manager (Track A: Linux)

&nbsp;

|                 |                                   |
| --------------- | --------------------------------- |
| **Student:**    | Romanov Dana, group FAF-241     |
| **Checked by:** | Patricia Reițman |

&nbsp;

**Chișinău, 2026**

---

## 1. Purpose of the work

To observe four core jobs of an operating system (file, process, memory and device management) on a Linux virtual machine, and to record what each command shows about how the OS manages resources.

## 2. Environment

| Item | Value |
| --- | --- |
| User (`whoami`) | dana |
| Kernel (`uname -a`) | Linux Ubuntu 7.0.0-43-generic #43-Ubuntu SMP PREEMPT_DYNAMIC Fri Oct 23 13:25:25 UTC 2026 x86_64 GNU/Linux |
| Uptime (`uptime`) | 15:26:43 up 19 min, 1 user, load average: 0.02, 0.03, 0.09 |

## 3. Progress of the work

### 3.1 Files and directories (file management)

**Interesting output** (`chmod 600 note.txt`, then `ls -l note.txt`):
```
-rw-rw-r-- 1 dana dana 24 Nov 21 15:36 note.txt     (before chmod 600)
-rw------- 1 dana dana 24 Nov 21 15:36 note.txt     (after chmod 600)
```

**Observations:**
1. The new files (`note.txt`, `renamed.txt`) are owned by the user `dana` and belong to the group `dana`. The OS stores an owner and a group for every file so it can decide who may access it.
2. After `chmod 600`, `ls -l` shows `-rw-------`. The first character `-` means a regular file. The next three, `rw-`, are the owner's permissions (read and write, no execute). The next three, `---`, are the group's permissions (none), and the last three, `---`, are everyone else's (none). Before `chmod` the file was `-rw-rw-r--`, so the group could also write and others could read.
3. Two directories under `/`: `/etc` holds the system's configuration files, and `/home` holds the users' personal directories (e.g. `/home/dana`).

### 3.2 Processes (process management)

**Interesting output** (`ps aux | head`, first lines):
```
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.1  0.3  26072 11424 ?        Ss   15:06   0:05 /usr/lib/systemd/systemd --switched-root --system --deserialize=55
root           2  0.0  0.0      0     0 ?        S    15:06   0:00 [kthreadd]
```

**Observations:**
1. PID 1 is `systemd` (`/usr/lib/systemd/systemd`). It is the first process started by the kernel at boot. Every other process descends from it, and it starts and manages the system's services.
2. `ps aux | wc -l` printed 219. One of those lines is the header, so about 218 processes are running on the idle VM. `top` agreed: 217 tasks in total, 214 sleeping, 1 running, 2 zombie, with the CPU 97.5% idle. Most processes are sleeping, waiting for an event, and many are kernel threads (shown in brackets, e.g. `[kthreadd]`).
3. For the `sleep` process (PID 8562), `/proc/8562/status` shows `State: S (sleeping)`. The process is waiting for its 300-second timer and uses no CPU in the meantime. The same file shows `PPid: 5272`, the shell that started it, so processes form a parent and child tree. After `kill`, the shell reported `Terminated`.

### 3.3 Memory (memory management)

**Interesting output** (`free -h`):
```
               total        used        free      shared  buff/cache   available
Mem:           3.3Gi       2.6Gi       187Mi        93Mi       763Mi       770Mi
Swap:             0B          0B          0B
```

**Observations:**
1. The VM has 3.3 GiB of total RAM (`MemTotal: 3480320 kB`), of which 2.6 GiB is used and only 187 MiB is completely free. The "available" figure, 770 MiB, is more meaningful than "free" because it includes cache that the OS can reclaim when programs need memory.
2. Swap is disk space the OS can use as overflow when RAM fills up, by moving rarely used memory pages out to disk. On this VM swap is 0 B, so none is configured and the system cannot offload memory to disk.
3. For the `sleep` process, `VmRSS` is 8148 kB (about 8 MB). This is the part of the process's memory that is actually resident in physical RAM. It is small compared with 3.3 GiB, but larger than a program that only sleeps might seem to need, because it also counts the shared libraries (e.g. libc) it has loaded. Those pages are shared with other processes, so the real extra cost is lower.

### 3.4 Devices and storage (I/O management)

**Interesting output** (`lsblk`, disk lines):
```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda      8:0    0  30.1G  0 disk 
├─sda1   8:1    0     1M  0 part 
└─sda2   8:2    0  30.1G  0 part /
sr0     11:0    1  1024M  1 rom  
```

**Observations:**
1. The root directory `/` is mounted on the device `/dev/sda2`. `df -h` shows it is 30 GB in size with 6.8 GB used (25%), and `mount` shows it uses the ext4 filesystem. `lsblk` confirms that `sda2` is a partition of the virtual disk `sda` (30.1 GB) mounted at `/`.
2. One entry in `/dev` is `/dev/cdrom`. `ls -l` shows it is a symbolic link (first character `l`) pointing to `sr0`, the virtual optical drive (it appears in `lsblk` with TYPE `rom`). Another is `/dev/console`, a character device (first character `c`) that represents the system console. Programs do not talk to the hardware directly: they open these files and the kernel's drivers handle the real device.
3. "Everything is a file" means the OS gives disks, terminals and other devices a path in the filesystem (such as `/dev/sda` or `/dev/console`), so they can be accessed with the same file operations (open, read, write) as ordinary files. Even `/proc`, which exposes process and memory information, is read as files, as seen with `/proc/PID/status`.

## 4. Conclusions

The operating system manages four resources: files, processes, memory and devices. I saw files with `ls -l` and processes with `ps aux`. I saw memory with `free -h` and devices and storage with `lsblk`.
