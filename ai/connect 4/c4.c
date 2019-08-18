#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define ONBOARD(x,y) (x>=0&&x<=6&&y>=0&&y<=5)
#define MAKEM(m,c)     cb[m.x][m.y]=c;
#define UNMAKEM(m)     cb[m.x][m.y]='u';
#define HEIGHT 6
#define WIDTH 7
/*
    i(computer) am BLACK my opponent(human) is RED
*/
int victory();
int Min(int depth);
void pb();
char (cb[WIDTH][HEIGHT]);

typedef struct move{
    int x,y;
}move;

int init(){
        for(int i=0;i<WIDTH;i++){
        for(int j = 0;j<HEIGHT;j++){
            cb[i][j]='x';
        }
    }
    pb();
}

int Evaluate(char c){//evaluates current board state
    int e,v;
    v=e=0;
    for(int i=0;i<WIDTH;i++){
        for(int j = 0;j<HEIGHT;j++){
            if(ONBOARD(i,j)){
                if(cb[i][j]==c){
                    switch(j){
                        case 0:{e++;
                        break;}
                        case 1:{e+=2;
                        break;}
                        case 2:{e+=3;
                        break;}
                        case 3:{e+=4;
                        break;}
                        case 4:{e+=3;
                        break;}
                        case 5:{e+=2;
                        break;}
                        case 6:{e++;
                        break;}
                    }
                }
            }
        }
    }
    v=victory();
    if(v==1)return 100;
    else if(v==-1)return -1;
    return e;
}

void UnmakeMove(int x){  
    int i=0;
    while(cb[x][i]!='R'&&cb[x][i]!='B'&&i<=6)i++;
    cb[x][i]='x';
    //printf("unmade %d\n",i);
    //pb();
}


int makeMove(int x,char c){
    int i=0;
    if(cb[x][0]=='R'||cb[x][0]=='B'||i>WIDTH||i<0)return -1;
    while(cb[x][i]!='R'&&cb[x][i]!='B'&&i<6)i++;
    if(cb[x][i-1]!='R'&&cb[x][i-1]!='B'){
        cb[x][i-1]=c;
        return 0;
    }
    //printf("made %d\n",i);
    //pb();
    return 0;
}

int Max(int depth) { 
    int best = -1;
    int val;

    if (depth<=0) return Evaluate('B');//eval black

    for(int i=0;i<7;i++){
        if( makeMove(i,'B')!=-1){
            val = Min(depth-1);
            UnmakeMove(i);
            if(val>best)best=val;
        }
    }
    return best;
}

int Min(int depth) {
    int best = 100;
    int val;

    if(depth <=0) return Evaluate('R');//eval red
    for(int i=0;i<6;i++){
        if( makeMove(i,'R')!=-1){
            val = Max(depth-1);
            UnmakeMove(i);
            if(val<best)best=val;
        }
    }
    return best;
}

//recursive win checker. takes a point on a board and a vector. if the vector is 0 then it knows it starts from that point otherwise it will be 1-8 to indicate the direction to check

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

void pb(){//prints current board
    for(int i=0;i<6;i++){
        for(int j=0;j<7;j++){
            printf("|%c",cb[j][i]);
        }
        printf("|\n");
    }
    printf("\n\n\n\n\n\n\n\n\n");
    
}

int startgame(c)//starts game with the color starting first
char *c;
{
    int winners,t,r,v;
    winners=0;
    if(!strcmp(c,"Red")){
        t=1;
    }
    else if(!strcmp(c,"Black")){
        t=0;
    }
    else {return -1;}

    while(winners==0){
        if(t%2==0){                  //black move
            int best[2],w[7];
            for(int i=0;i<7;i++){
                if(makeMove(i,'B')!=-1){
                    w[i]=Min(5);
                    UnmakeMove(i);
                }
                if(best[0]<w[i]){
                    best[0]=w[i];
                    best[1]=i;
                }
            }
            makeMove(best[1],'B');
            /*
            for(int i=0;i<7;i++){
                printf("w%d %d\n",i,w[i]);
            }
            printf("best 0,%d best 1,%d \n",best[0],best[1]);
            */

        }
        else{                        //red move
            printf("what coloum would you like to place your peice?\n");
            scanf("%d",&r);
            MOVE:
            if(makeMove(r,'R')==-1){
                    printf("you cant do that please go again\n");
                    goto MOVE;
            }
        }
        pb();
        v = victory();
        if(v==1){
            printf("black has won the game\n");
            goto END;
        }
        else if(v==-1){
            printf("red has won the game\n");
            goto END;
        }
        t++;
    }
    END:
    return 1; //game was played to finish
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
else {printf("oh ok have a nice day \nint victor(char c); \\[T]// \n PRAISE THE SUN\n\n\n");}
*/
    
}