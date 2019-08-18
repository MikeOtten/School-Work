                                                                       #include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define ONBOARD(x,y) (x>=0&&x<=6&&y>=0&&y<=5)
#define LOOP for(int i=0;i<6;i++){for(int j=0;j<7;j++){
#define END }}
#define MAKEM(m,c)     cb[m.x][m.y]=c;
#define UNMAKEM(m)     cb[m.x][m.y]='u';
#define HEIGHT 6
#define WIDTH 7

char (cb[HEIGHT][WIDTH]);
int Min(int depth);


int init(){
    for(int i=0;i<HEIGHT;i++){
        for(int j=0;j<WIDTH;j++){
            cb[i][j]='x';
        }
    }
}

typedef struct move{
    int x,y;
}move;


void pb(){//prints current board
    for(int i=0;i<HEIGHT;i++){
        for(int j=0;j<WIDTH;j++){
            printf("|%c",cb[i][j]);
        }
        printf("|\n");
    }
    printf("\n\n\n\n\n");
    
}

int victory(){//1=black wins 0= no one wins -1 = red wins
   //check down
   for(int i=0;i<HEIGHT-3;i++){
       for(int j=0;j<WIDTH;j++){
           if(cb[i][j]==cb[i+1][j]&&cb[i][j]==cb[i+2][j]&&cb[i][j]==cb[i+3][j]){
               if(cb[i][j]=='B')return 1;
               else if(cb[i][j]=='R')return -1;
            }
        }
    }
    //check across
    for(int i=0;i<HEIGHT;i++){
        for(int j=0;j<WIDTH-3;j++){
            if(cb[i][j]==cb[i][j+1]&&cb[i][j]==cb[i][j+2]&&cb[i][j]==cb[i][j+3]){
                if(cb[i][j]=='B')return 1;
                else if(cb[i][j]=='R')return -1;
            }
        }
    }
    //check left diagonal
    for(int i=0;i<HEIGHT-3;i++){
        for(int j=0;j<WIDTH-3;j++){
            if(cb[i][j]==cb[i+1][j+1]&&cb[i][j]==cb[i+2][j+2]&&cb[i][j]==cb[i+3][j+3]){
                if(cb[i][j]=='B')return 1;
                else if(cb[i][j]=='R')return -1;
            }
        }
    }
    //check right diagonal
    for(int i=0;i<HEIGHT-3;i++){
        for(int j=3;j<WIDTH;j++){
            if(cb[i][j]==cb[i+1][j-1]&&cb[i][j]==cb[i+2][j-2]&&cb[i][j]==cb[i+3][j-3]){
                if(cb[i][j]=='B')return 1;
                else if(cb[i][j]=='R')return -1;
            }
        }
    }
    return 0;
}

int Evaluate(char c){
    int s =0;
    LOOP
        if(cb[i][j]==c){
            switch(i){
                case 0:{s++;
                    break;}
                case 1:{s+=2;
                    break;}
                case 2:{s+=3;
                    break;}
                case 3:{s+=4;
                    break;}
                case 4:{s+=3;
                    break;}
                case 5:{s+=2;
                    break;}
                case 6:{s++;
                    break;}
            }
        }
    END
    printf("%d\n",s);
    return s;
}

int Max(int depth){ 
    int best = -1;
    int val;

    if (depth<=0) return Evaluate('B');//eval black

    for(int j=0;j<WIDTH;j++){
        int i=0;
        while(j<HEIGHT&&cb[j][i]=='u'||cb[j][i]=='x')j++;
        move m = {i,j};
        MAKEM(m,'B')
        val = Min(depth-1);
        UNMAKEM(m)
        if(val>best)best=val;
    }
    return best;
}

int Min(int depth) {
    int best = 100;
    int val;

    if (depth<=0) return Evaluate('B');//eval black
    
    for(int j=0;j<WIDTH;j++){
        int i=0;
        while(j<HEIGHT&&cb[j][i]=='u'||cb[j][i]=='x')j++;
        move m = {i,j};
        MAKEM(m,'R')
        val = Max(depth-1);
        UNMAKEM(m)
        if(val<best)best=val;
    }
    return best;
}

void startgame(c)
char* c;
{
    int w,t,mm,r;
    int b[2];
    int m[7];
    if(!strcmp(c,"Red")){
        t=1;
    }
    else if(!strcmp(c,"Black")){
        t=0;
    }
    else {return;}

    w=0;
    while(w==0){
        pb();
        if(t%2==0){//Black
            b[0]=100;
            b[1]=0;
            for(int i=0;i<7;i++){
                int j=0;
                while(j<HEIGHT&&cb[i][j]!='R'&&cb[i][j]!='B')j++;
                move mi = {i,j-1};
                MAKEM(mi,'B')
                m[i]=Min(4);
                UNMAKEM(mi)
                if(m[i]<b[0]){
                    b[0]=m[i];
                    b[1]=i;
                }
            }
            int j=0;
            while(j<HEIGHT&&cb[b[0]][j]!='R'&&cb[b[0]][j]!='B')j++;
            move mi = {b[0],j-1};
            MAKEM(mi,'B')
        }
        else{//Red
            printf("Red turn\n");
            MOVE:
            printf("what coloum would you like to place your peice?\n");
            scanf("%d",&r);
            if(ONBOARD(0,r)){
                    printf("you cant do that please go again\n");
                    goto MOVE;
            }
            //MAKEM
        }
        t++;

        int v=victory();
        if(v==1){
            printf("Black wins");
            w=1;
        }
        else if(v==-1){
            printf("Red wins");
            w=1;
        }
    }
}


void main(argc, argv, envp)
int argc;
char **argv, **envp;
{
    init();
    char r[3];
    startgame("Black");
/*
printf("would you like to play a game(yes/no)\n");
scanf("%s",r);
if(!strcmp(r,"yes")){
    printf("would you like to go first(yes/no)\n");
    scanf("%s",r);
    if(!strcmp(r,"yes")){
        startgame("Red");
    }
    else{
        startgame("Black");
    }
}
else {printf("oh ok have a nice day \n \\[T]// \n PRAISE THE SUN\n\n\n");}
*/
    
}
/*

|'x'|'x'|'x'|'x'|'x'|'x'|'x'|
|'x'|'x'|'x'|'x'|'x'|'x'|'x'|
|'x'|'x'|'x'|'x'|'x'|'x'|'x'|
|'x'|'x'|'x'|'x'|'x'|'x'|'x'|
|'x'|'x'|'x'|'x'|'x'|'x'|'x'|
|'x'|'x'|'x'|'x'|'x'|'x'|'x'|

*/