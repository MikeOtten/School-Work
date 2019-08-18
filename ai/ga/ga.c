/* genetic algorithm to maximiz a function of 8 variables */
/* the 8 variables constitue the genome for an individual */
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
#include <values.h>


#define PSIZE 32		/* size of population */
#define NGEN UINT_MAX		/* evolutionary bound */

int dbg=0;
double **pop;			/* the population, crossover happens in situ */

struct vs {			/* one of these for each individual, holds fitness and index into pop */
	double v;
	int w;
};



/* fitness function */
double
eval(p)
double *p;
{
	int i;
	return((cos((sin(p[0]) + 1.0/(1.0 - exp(p[1])) - p[2]/819.0 + p[3] - exp(sin(p[4])) - p[5])) * tan(-1.5708)) + p[7]/1000.0);
}


init()  {
	int i,j;

	pop = (double **) calloc(PSIZE, sizeof(double *));
	for (i=0; i<PSIZE; i++) {
		pop[i] = calloc(8, sizeof(double));
		for (j=0; j<8; j++)
			pop[i][j] = 0.001 * ((double)(rand() - RAND_MAX/2));
	}
}


/* compare function for quciksort */
int
dcmp(a,b)
struct vs *a, *b;
{
	if (a->v < b->v) return(-1);
	if (a->v > b->v) return(1);
	return(0);
}



/* for output when dbg is set */
ppop(s)
char *s;
{
	int i,j;
	printf("%s", s);
	for (i=0; i<PSIZE; i++)  {
		printf("%d: ", i);
		for (j=0; j<8; j++)
			printf("%6.4f ", pop[i][j]);
		printf("\n");
	}
}


main (argc, argv, envp)
int argc;
char **argv, **envp;
{
	char *s;
	register unsigned int  i, j, gen, nf;
	struct vs vals[PSIZE], best;


	best.v= -DBL_MAX;
	best.w = -1;

	/* get space and set initial random values for traits */
	init();


	if (s=getenv("DBG")) dbg = atoi(s);


	/* evolution loop */
	for (gen=0; gen<NGEN; gen++) {
		if (dbg) printf("generation %d: ", gen);


		/* find fitness for everyone */
		for (i=0; i<PSIZE; i++) {
			vals[i].v = eval(pop[i]);
			vals[i].w = i;
		}

		
		qsort(vals, PSIZE, sizeof(struct vs), dcmp);


		/* print this one if we have taken a step upward */
		if (vals[PSIZE-1].v > best.v) {
			printf("generation %d: ", gen);
			best.v = vals[PSIZE-1].v;
			best.w = vals[PSIZE-1].w;
			printf("%f - ", best.v);
			for (i=0; i<8; i++)
				printf("%6.4f ", pop[best.w][i]);
			printf("\n");
		}
		if (dbg) for (i=0; i<PSIZE; i++) printf("vals[%d].v = %f   %d\n", i, vals[i].v, vals[i].w);

		if (dbg>1) ppop("before:\n");

		/* breed, elitist strategy. Top n/2 mate (n/ couples) and have 2 offspring each to replace the least fit n/2 */
		nf=0;
		for(i=PSIZE/2; i<PSIZE; i+=2) {
			pop[nf][0] = pop[vals[i].w][3]; pop[nf][1] = pop[vals[i].w][4]; pop[nf][2] = pop[vals[i].w][5]; pop[nf][3] = pop[vals[i].w][6];
			pop[nf][4] = pop[vals[i+1].w][1]; pop[nf][5] = pop[vals[i+1].w][2]; pop[nf][6] = pop[vals[i+1].w][0]; pop[nf][7] = pop[vals[i+1].w][7];
			nf++;
			pop[nf][0] = pop[vals[i].w][0]; pop[nf][1] = pop[vals[i].w][1]; pop[nf][2] = pop[vals[i].w][2]; pop[nf][3] = pop[vals[i].w][3];
			pop[nf][4] = pop[vals[i+1].w][4]; pop[nf][5] = pop[vals[i+1].w][5]; pop[nf][6] = pop[vals[i+1].w][7]; pop[nf][7] = pop[vals[i+1].w][6];
			nf++;

			/* mutation */
			if ((rand() & 64) >= 16)
				pop[nf][rand() % 8] -= (double) 1.0;
			if ((rand() & 64) >= 63)
				pop[nf][rand() % 8] = cos(pop[nf][rand() % 8]);
		}

		if (dbg>1) ppop("\nafter:\n");
	}
}


