#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>
#include <sys/time.h>

#define CONVERT(s) ((double)s.tv_sec+(double)(s.tv_usec*.0000001))



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
saves[turn]=v;
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
	while (go && (v > -200.0)) {
		printf("0");fflush(stdout);
		t = (rand() % 1024);
		v -= 2.0;
		if ((v>0.0) || ((((int) v) % 2) == -1)) {
			printf("f0, found odd or positive, v= %f\n", v);
			exit(1);
		}
		usleep(t*100);
	}
	if (v <= -200.0) virgins[0]=1;
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
	while (go && (v > -401.0)) {
		printf("1");fflush(stdout);
		t = (rand() % 2048);
		v -= 2.0;
		if ((v>0.0) || ((((int) v) % 2) != -1)) {
			printf("f1, found even or positive\n");
			exit(1);
		}
		usleep(t*100);
	}
	if (v <= -401.0) virgins[1]=1; 
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

void main(argc, argv, envp)
int argc;
char **argv, **envp;
{
	int pid,x,rr,t[4];
	double st,ps;
	int jc=0;
	struct timeval chrono;

    float vv[4][3];
	virgins[0]=virgins[1]=virgins[2]=virgins[3]=1;
	vv[0][1]=vv[1][1]=vv[2][1]=vv[3][1]=0;
	vv[0][2]=vv[1][2]=vv[2][2]=vv[3][2]=0;	
	procs[0]=f0;
	procs[1]=f1;
	procs[2]=f2;
	procs[3]=f3;
	gettimeofday(&chrono,NULL);
	st=CONVERT(chrono);
	x=rr=0;
	signal(SIGUSR1, cpusched);
	if (pid=fork()) {
		while (1) {
			sleep(1);
			kill(pid, SIGUSR1);
		}
	} else {
		while (1) {
			v = vv[turn][0];

			gettimeofday(&chrono,NULL);
			ps = CONVERT(chrono);
			procs[turn](virgins[turn]);
			gettimeofday(&chrono,NULL);
			ps = CONVERT(chrono) - ps;
			if(ps<=1)jc++;
			vv[turn][2]++;
			vv[turn][1]=(vv[turn][1]+ps);
            vv[turn][0] = v;
			turn++;
			x++;
			if(x>=50)break;
			



			if(x>8){
				if(rr==0||rr==4){
					rr=0;
					int tt[4];
					for(int i=0;i<4;i++)tt[i]=vv[i][1]/vv[i][2];
					for(int i=0;i<4;i++){
						int best[2];
						best[0]=99;
						for(int j=0;j<4;j++){
							if(best[0]>tt[i]&&tt[i]!=NULL){
								best[0]=tt[i];
								best[1]=i;
							}
						}
						tt[best[1]]=NULL;
						t[i]=best[1];
					}
				}
				turn = t[rr];
				rr++;
			}
			else if (turn==4) turn=0;
		}
END:
		printf("\nchild exit\n");
		gettimeofday(&chrono,NULL);
		st = CONVERT(chrono)-st;
		double throughput = (double)(jc/st);
		printf("\n\n\n\n\n %f seconds is the total time.  %d jobs were completed\nso a throughput of %f jobs per second was achived\n",st,jc,throughput);
		
	}
}
