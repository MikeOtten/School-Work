#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define HEAPSIZE 32768

int bb[HEAPSIZE][2],tz,ch;//blackbook records all, total size,current head
char* heap;


init(){
	heap = malloc(HEAPSIZE);
	//bb[HEAPSIZE][2];
	tz = ch = 0;
}

//return pointer to space or -1 on failure
int*
mall(sz)
int sz;
{
	if(sz>HEAPSIZE||sz<0)return -1;
	bb[ch][0]=tz+1;
	bb[ch][1]=sz;
	tz+=sz;
	ch++;
	return &bb[ch-1][0];
}

void
fre(ptr)
int *ptr;
{
	int i=0;
	while(bb[i][0]!=*ptr)i++;
	bb[i][0]=NULL;
	tz-=bb[i][1];
	bb[i][1]=0;
}

main(argc, argv, envp)
int argc;
char **argv, **envp;
{
	int j=0;
	while(j<argc)
	{
		if(strcmp(argv[j],"free"))
		{
			fre((int)argv[j+1]);
		}
		else if(strcmp(argv[j],"malloc"))
		{
			int r=mall((int)argv[j+1]);
			printf("%s",r);
		}
		else
		{
			printf(argv[j]);
			printf(" was not a valid input");
		}
		j+=2;
	}
}
