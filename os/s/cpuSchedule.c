#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>


int virgins[4];
float saves[4];
int go=1;
int turn=0;
float v;
int (*procs[4])(int);

void
cpusched(signum)
int signum;
{
	virgins[turn]=0;
	go=0;
}


int
f0(x)
int x;
{
	register int i=0;
	register int t;
	signal(SIGUSR1, cpusched);
	if (!x) goto start;
	v=0.0;

start:
	while (go) {
		printf("0");fflush(stdout);
		t = (rand() % 4096);
		v -= 2.0;
		if ((v>0.0) || ((((int) v) % 2) == -1)) {
			printf("f0, found odd or positive, v= %f\n", v);
			exit(1);
		}
		usleep(t*100);
	}
	go=1;
}



int
f1(x)
int x;
{
	register int i=0;
	register int t;
	if (!x) goto start2;
	v= -1.0;

start2:
	while (go) {
		printf("1");fflush(stdout);
		t = (rand() % 4096);
		v -= 2.0;
		if ((v>0.0) || ((((int) v) % 2) != -1)) {
			printf("f1, found even or positive\n");
			exit(1);
		}
		usleep(t*100);
	}
	go=1;
}


int
f2(x)
int x;
{
	register int i=0;
	register int t;
	if (!x) goto start3;
	v= 1.0;

start3:
	while (go) {
		printf("2");fflush(stdout);
		t = (rand() % 4096);
		v += 2.0;
		if ((v<0.0) || ((((int) v) % 2) != 1)) {
			printf("f2, found even or negative\n");
			exit(1);
		}
		usleep(t*100);
	}
	go=1;
}


int
f3(x)
int x;
{
	register int i=0;
	register int t;
	if (!x) goto start4;
	v= 0.0;

start4:
	while (go) {
		printf("3");fflush(stdout);
		t = (rand() % 4096);
		v += 2.0;
		if ((v<0.0) || ((((int) v) % 2) == 1)) {
			printf("f3, found odd or negative\n");
			exit(1);
		}
		usleep(t*100);
	}
	go=1;
}



main(argc, argv, envp)
int argc;
char **argv, **envp;
{
	int pid;

	virgins[0]=virgins[1]=virgins[2]=virgins[3]=1;
	procs[0]=f0;
	procs[1]=f1;
	procs[2]=f2;
	procs[3]=f3;
	signal(SIGUSR1, cpusched);
	if (pid=fork()) {
		while (1) {
			sleep(5);
			kill(pid, SIGUSR1);
		}
	} else {
		while (1) {
			procs[turn](virgins[turn]);
			turn++;
			if (turn==4) turn=0;
		}
	}
}

