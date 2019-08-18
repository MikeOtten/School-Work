#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

int main(argc, argv, envp)
int argc;
char **argv, **envp;
{
char buf[1024];

        memset(buf, 0, 512);
        int f0=open(argv[1], O_RDONLY);
        if(f0 == -1){
			printf("Error: opening boot file.\n");
			exit(-1);	
		}
        int rr=read(f0, buf, 510);
        printf("read success %d", rr);
        close(f0);

        buf[510] = 0x55;
        buf[511] = 0xaa;

        int f1 = open("/dev/fd0", O_RDWR);
		if(f1 == -1){
			printf("Error: opening flopy disk.\n");
		}
        rr = write(f1, buf, 512);
        printf("write success %d", rr);

		/* Finised putting boot loader on disk*/

		memset(buf,0,1024);
		f0 = open(argv[2],O_RDONLY);
		if(f0 == -1){
			printf("Error: opening OS file.\n");
			exit(-1);	
		}	
		rr = read(f0,buf,1024);
		printf("read success %d", rr);
		close(f0);
		rr = write(f1,buf,1024);

        close(f1);
		
}





