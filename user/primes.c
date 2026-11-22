#include "kernel/types.h"
#include "user/user.h"

// One stage of the chain: the first number it reads is a prime. It prints it,
// creates the next stage and forwards only the numbers not divisible by it.
void stage(int rd) __attribute__((noreturn));

void
stage(int rd)
{
  int p, n;
  if(read(rd, &p, sizeof(p)) != sizeof(p)){
    close(rd);
    exit(0);
  }
  printf("prime %d\n", p);
  int fds[2];
  pipe(fds);
  if(fork() == 0){
    close(fds[1]);
    close(rd);
    stage(fds[0]);
  }
  close(fds[0]);
  while(read(rd, &n, sizeof(n)) == sizeof(n)){
    if(n % p != 0)
      write(fds[1], &n, sizeof(n));
  }
  close(rd);
  close(fds[1]);
  wait(0);
  exit(0);
}

int
main(int argc, char *argv[])
{
  int fds[2];
  pipe(fds);
  if(fork() == 0){
    close(fds[1]);
    stage(fds[0]);
  }
  close(fds[0]);
  for(int i = 2; i <= 35; i++)
    write(fds[1], &i, sizeof(i));
  close(fds[1]);
  wait(0);
  exit(0);
}
