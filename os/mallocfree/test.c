#include <stdio.h>
#include <stdlib.h>
#include <string.h>




struct chunk {
	int sz;
	char *p;
};

int val = ';';
main(argc, argv, envp)
int argc;
char **argv, **envp;
{

	int i,j,s;
	struct chunk d[32];

	initmm();

	for (i=0; i< 32; i++) {
		s = rand() %64;
		d[i].sz = s;
		d[i].p = mall(s);
		for (j=0; j<s; j++) d[i].p[j] = val;
		val++;
	}

	for (i=0; i< 32; i++) {
		if (i%2) {
			fre(&d[i].p);
			d[i].sz=0;
		}
	}

	for (i=0; i<32; i++) {
		if (d[i].sz) {
			printf("%d: ", i);
			for (j=0; j<d[i].sz; j++)
				printf("%c ", d[i].p[j]);
			printf("\n\n");
		}
	}

}

