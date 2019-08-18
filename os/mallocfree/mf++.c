#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define HEAPSIZE 32768 // 32768/64 = 512

//make malloc and free with the map struct

/*

cc -c mm.c
cc -o test test.c mm.o
mm.c has mm() and mf()

*/

struct map
{
	char *m_size;
	char *m_addr;
};

char* heap;
struct map *mm;

void init(){
	heap = malloc(HEAPSIZE);
	mm= malloc(sizeof(struct map)*512);
	mm[511].m_size = 0;
}

//return pointer to space or -1 on failure
int*
mall(mp)
struct map *mp;
{
	int x;
	struct map *tm;
printf("2/n");
	for(tm=mp;tm->m_size;tm++){
		if(tm->m_size >= mp->m_size){
			x = &tm->m_addr;
			tm->m_addr +=(int)mp->m_size;
			if((tm->m_size -=mp->m_size)==0){
				tm++;
				tm->m_addr = (tm-1)->m_addr;
			}
			return x;
		}
	}
	return -1;

}

void
fre(mp,ptr)
int *ptr;
struct map *mp;
{
	struct map *tm;
	for(tm = mp;tm->m_addr<=ptr && tm->m_size != 0;tm++);
	tm->m_size += ((int*)tm->m_addr-ptr);
	tm->m_addr = ptr;
}

/*
initmm(){
	int e;
	printf("pre");
	init();
	printf("1/n");
	e = mall(mm,300);
	fre(mm,(int*)e);
	printf("Done");
}
*/

main(argc, argv, envp)
int argc;
char **argv, **envp;
{
	int e;
	printf("pre");
	init();
	printf("1/n");
	e = mall(mm,300);
	fre(mm,(int*)e);
	printf("Done");
}
