#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <time.h>
#include <unistd.h>

//#define LERAND 3
/*  we get a pointer to a shared memory segment
    then check for contiguesness and print based on what you found
    genereate a set of random values
    and sleep based on what is in those values from 0 to args[2]

    args[1] is the shm pointer args[2] is the max sleep in seconds reader id is args[3]
*/

int reader(char *shmidy,int rem,int rid){//shmidy is the shared memory pointer rem is the max sleep length(seconds) and rid is the readers id
    int r[3];
    //shmat(shmidy,data,SHM_RDONLY);
    //srand();
    for(int i = 0; i < 3; i++){
        r[i] = rand() % rem;
    }
    sleep(r[1]);
    //read w/ if
    char x = shmidy[0];
    for(int i = 1; i<1048576; i++){
        if(x==shmidy[i]){
            sleep(r[2]);
            printf("id %d ITS A MATCH\n",rid);
        }
        else{
            sleep(r[2]);
            printf("id %d WARNING WARNING NOT A MATCH NOT A MATCH I REPEAT NOT A MATCH\n",rid);
        }
    }
    sleep(r[3]);

    return 1;
}

/*
int main(argc, argv, envp)
int argc;
char **argv, **envp;
{

}
*/