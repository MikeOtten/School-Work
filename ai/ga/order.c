#include <stdio.h>

char *list[] = {"mia", "lga", "lax", "sfo", "dfw", "bdl", "bos", "ord", "phy", "yvr", 0};
main() {
        int i;
        char *s;

        for (i=0; s=list[i++]; )  printf("%s\n", s);
}

