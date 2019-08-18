#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>


int reader() // the reader of the shared mem segment
{

}

int writer() //the writer of the shared mem segment
{

}

int main(argc, argv, envp)
int argc;
char **argv, **envp;
{
    int shid,key;
    int nr = atoi(argv[1]);
    int nw = atoi(argv[2]);
    char* shmep;
    key=666;

    if(shid = shmget(key,16384,0666 | IPC_CREAT | IPC_EXCL)); //trap this !!!
    shmep = shmat(shid,NULL,0); // TRAP THIS !!!
    
    //for(int i=0;i<16384;i++) *(shmep+i) = 0x30;
    memset(shmep,0x30,16384);
}

/*  creat the shared memory segment
    fork and exec the amount of readers and writer
    during the creation of readers set a variable to 0 then fork
    during the creation of writers set a variable to 1 then fork
    sit back and twidle thy thumbs at this point
*/