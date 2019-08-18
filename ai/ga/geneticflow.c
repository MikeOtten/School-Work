//genetic algorythm to solve a traveling sales man problem for december 5th 2017
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <values.h>
#include <limits.h>

#define NGEN UINT_MAX   // generation bound
#define CHERNOBYL 26

int dbg=0;

int prices[10][10] = { // first [] = FROM second [] = TO
	0,   44,  62,  99,  53,  40,  59,  32,  119, 123,	    /* mia */
	28,  0,   123, 126, 64,  106, 49,  40,  149, 131,	    /* lga */
	70,  116, 0,   39,  50,  157, 118, 46,  73,  59,	    /* lax */
	98,  120, 40,  0,   86,  157, 109, 91,  91,  102,	    /* sfo */
	52,  88,  41,  77,  0,   138, 93,  40,  45,  118,	    /* dfw */
	46,  106, 184, 157, 139, 0,   95,  156, 146, 168,	/* bdl */
	65,  48,  118, 108, 82,  125, 0,   49,  158, 130,	    /* bos */
	40,  40,  47,  77,  41,  105, 50,  0,   36,  169,	    /* ord */
	93,  123, 76,  91,  46,  177, 159, 40,  0,   103,	    /* phx */
    154, 156, 85,  126, 159, 176, 156, 171, 113, 0};	/* yvr */

typedef struct inf{
    int p,cc;//price and which child it is
}info;

int cgen[20][10];
int best[10];
int bestset = 0;

int eval(p)
int p;
{
    int x = 0;
    for(int i =0;i<9;i++){
        x += prices[cgen[p][i]][cgen[p][i+1]];
    }
    return x;

    /*for(int i = 0;i<9;i++){
        p->price+=prices[p->route[i]][p->route[i+1]];
    }*/
}

int bval(p)
int *p;
{
    int x = 0;
    for(int i =0;i<9;i++){
        x += prices[p[i]][p[i+1]];
    }
    return x;
}

int init(){
    time_t t;
    srand(time(NULL));
    //filling array 0-9 and shuffle a random number of times
    int s,ss,sss;
    int start[] = {0,1,2,3,4,5,6,7,8,9};
    for(int i = 0;i<20;i++){
        for(int j = 0;j<10;j++)cgen[i][j] = start[j];
    }

    for(int i = 0;i<20;i++){
        int randy = rand()%50+50;
        for(int j=0;j<randy;j++){
            s = rand()%10;
            ss = rand()%10;
            sss = cgen[i][s];
            cgen[i][s] = cgen[i][ss];
            cgen[i][ss] = sss;
        }
    }
}

//compare for quicksort
int gcomp( a, b)
info *a, *b;
{
    if(a->p>b->p) return (1);
    if(a->p<b->p) return (-1);
    return 0;
}

//dbg print
int gprint(s)
char *s;
{
    printf("%s", s);
    for(int i=0;i<20;i++){
        printf("child %d: ",i);
        for(int j=0;j<10;j++){
            printf("%d ",cgen[i][j]);
        }
        printf("\n");
    }
}

int main (argc, argv, envp)
int argc;
char **argv, **envp;
{
    char *s;
    info fit[20];
    //set up - get space and set initial random values for traits 
    srand(time(0));
    init();
    printf("populated children");

    if (s=getenv("DBG")) dbg = atoi(s);// export DBG=1 to set
    //evolution loop 
    int besty,current,ssdd;
    ssdd = 0;
    for(int gen = 0;gen<NGEN;gen++){
        // find fitness
        for(int i = 0;i<20;i++){
            fit[i].p = eval(i);
            fit[i].cc = i;
        }

        qsort(fit, 20, sizeof(info), gcomp);// normally defines fit[0] as the smallest

        //print this one if we have taken a step upward 
        //printf("checking the best");
        besty = bval(best);
        current = eval(fit[0].cc);
        printf("besty:%d current:%d \n",besty,current);
        if(bestset == 0){
            bestset = 1;
            for(int i =0;i<10;i++)best[i] = cgen[fit[0].cc][i];
            printf("\nSET BESTSET\n");
        }
        else if(current<besty) {
            for(int i = 0;i<10;i++){
                best[i] = cgen[fit[0].cc][i];
            }
            printf("NEW BEST %d !!!!!!!!\n",bval(best));
        }
        else{
            ssdd++;
            if(ssdd==1000){

                printf("took %d (%d) generations to find the best      \ngood bye now\n",gen,gen-1000);
                exit(0);
            }
        }

        if (dbg>=1) printf("gen %d",gen);
        if (dbg>=1) gprint(":\n");
        //breed, elitist strategy. Top n/2 mate (n/ couples) and have 2 offspring each to replace the least fit n/2
        /*
            take the first 10 and use them to replace the last 10
            breeding occurs by selecting the first 3-5 locations and switching them with the order of the other parent
            ex 0,1,2,3,4,5,6,7,8,9 X 9,8,7,6,5,4,3,2,1,0 (3) == 2,1,0,3,4,5,6,7,8,9 and 9,8,7,6,5,4,3,0,1,2
        */
        for(int i=0;i<5;i++){
            int c1[10],c2[10],ct[10],randy;
            for(int k = 0;k<10;k++){
                c1[k] = cgen[(fit[2*i].cc)][k];
                c2[k] = cgen[(fit[(2*i)+1].cc)][k];
            }
            memcpy(ct,c1,(sizeof(int)*10));
            randy = (rand()%2)+3;
            int bs[randy];
            for(int k = 0;k<randy;k++){
                int j = 0;
                while(c1[k]!= c2[j] && j<10)j++;
                bs[k] = j;
            }

            for(int k=0;k<randy;k++){
                c1[k] = c2[bs[k]];
                c2[bs[k]] = ct[k];
            }

            for(int k=0;k<10;k++){
                cgen[(fit[(2*i)+10].cc)][k] = c1[k];
                cgen[(fit[(2*i)+11].cc)][k] = c2[k];
            }
        }
        //mutation - occurs by choosing a number n from 0-5 and switching it with n+4  around 25% chance of hapening
        for(int i =0;i<20;i++){
            int m = (rand()%100)+1;
            if(m<CHERNOBYL){
                int n = rand()%6;
                int j = cgen[i][n];
                cgen[i][n] = cgen[i][n+4];
                cgen[i][n+4] = j; 
            }
        }

        //if (dbg>=1) gprint("\nafter:\n");
    }
}