#!/usr/bin/env bash
# Lab 5 helper: runs every command of the sheet in ~/os-lab5 and saves everything to ~/os-lab5/outputs.txt
# Usage: bash lab5.sh
if [ "$(id -u)" -eq 0 ]; then echo "Run as your normal user, not root."; exit 1; fi
rm -rf ~/os-lab5; mkdir -p ~/os-lab5 && cd ~/os-lab5 || exit 1
OUT=~/os-lab5/outputs.txt
: > "$OUT"
run() { echo -e "\n\$ $*" | tee -a "$OUT"; bash -c "$*" 2>&1 | tee -a "$OUT"; }
part() { echo -e "\n=== $* ===" | tee -a "$OUT"; }

run "whoami"

part "PART 1: THE TREE AND THE FILE TYPES"
run "ls /"
run "ls -ld /etc /etc/passwd /bin /dev/null /tmp"
run "ls -l /dev | head"
run "file /usr/bin/ls /etc/passwd /bin"
run "du -sh /var/log 2>/dev/null ; du -sh /usr 2>/dev/null"

part "PART 2: INODES AND LINKS"
run "echo hello > notes.txt; stat notes.txt; ls -li notes.txt"
run "ln notes.txt hard.txt; ls -li notes.txt hard.txt"
run "rm notes.txt; cat hard.txt ; ls -li hard.txt"
run "ln -s hard.txt soft.txt; ls -li hard.txt soft.txt; cat soft.txt"
run "rm hard.txt; cat soft.txt ; ls -l soft.txt"
run "mkdir d ; ls -ld d"
run "mkdir d/x d/y ; ls -ld d"
run "echo x > one.txt ; ls -l one.txt ; du -h one.txt"
run "truncate -s 1G big.img ; ls -lh big.img ; du -h big.img; rm big.img"

part "PART 3: PERMISSIONS"
run "echo secret > s.txt; chmod 600 s.txt ; ls -l s.txt"
run "chmod 000 s.txt ; cat s.txt"
run "chmod u+r s.txt ; cat s.txt"
run "umask ; touch new.txt ; mkdir newdir ; ls -ld new.txt newdir"
run "mkdir box ; echo hi > box/f"
run "chmod u=r,go= box ; ls box ; cat box/f"
run "chmod u=x,go= box ; ls box ; cat box/f"
run "chmod 755 box"
run "ls -l /usr/bin/passwd ; ls -ld /tmp"
run "cat /etc/shadow"
run "ls -l /etc/shadow"

part "PART 4: DISKS AND THE KERNEL AS FILES"
run "lsblk"
run "df -h"
run "mount | grep ' / '"
run "grep -c processor /proc/cpuinfo"
run "head -3 /proc/meminfo"
run "head -5 /proc/self/status"
run "ls -l /proc/self/fd"

echo -e "\nDone. Open ~/os-lab5/outputs.txt, or paste what the terminal printed to Claude."
