#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define ONBOARD(x,y) (x>=0&&x<=6&&y>=0&&y<=5)
#define MAKEM(m,c)     cb[m.x][m.y]=c;
#define UNMAKEM(m)     cb[m.x][m.y]='u';
#define X 7
#define Y 6



char (cb[X][Y]);

typedef struct move{
    int x,y;
}move;

typedef struct intt{
    int score;
    move x;
}intt;
intt Min(int depth);
void pb(){//prints current board
    for(int i=0;i<6;i++){
        for(int j=0;j<7;j++){
            printf("|%c",cb[j][i]);
        }
        printf("|\n");
    }
    printf("\n\n\n\n\n\n\n\n\n");
    
}

int init(){
    for(int i=0;i<X;i++){
        for(int j = 0;j<Y;j++){
            cb[i][j]='x';
        }
    }
    pb();
}

int victory(){//1=black wins 0= no one wins -1 = red wins
    //check down
    for(int i=0;i<X;i++){
        for(int j=0;j<Y-3;j++){
            if(cb[i][j]==cb[i+1][j]&&cb[i][j]==cb[i+2][j]&&cb[i][j]==cb[i+3][j]){
                printf("found vertical victory!!");
                if(cb[i][j]=='B')return 1;
                else if(cb[i][j]=='R')return -1;
             }
         }
     }
     //check across
     for(int i=0;i<X-3;i++){
         for(int j=0;j<Y;j++){
             if(cb[i][j]==cb[i][j+1]&&cb[i][j]==cb[i][j+2]&&cb[i][j]==cb[i][j+3]){
                printf("found horizontal victory!!");                
                 if(cb[i][j]=='B')return 1;
                 else if(cb[i][j]=='R')return -1;
             }
         }
     }
     //check left diagonal
     for(int i=0;i<X-3;i++){
         for(int j=0;j<Y-3;j++){
             if(cb[i][j]==cb[i+1][j+1]&&cb[i][j]==cb[i+2][j+2]&&cb[i][j]==cb[i+3][j+3]){
                printf("found diagonal victory!!");
                 if(cb[i][j]=='B')return 1;
                 else if(cb[i][j]=='R')return -1;
             }
         }
     }
     //check right diagonal
     for(int i=0;i<X-3;i++){
         for(int j=3;j<Y;j++){
             if(cb[i][j]==cb[i+1][j-1]&&cb[i][j]==cb[i+2][j-2]&&cb[i][j]==cb[i+3][j-3]){
                printf("found diagonal victory!!");                
                 if(cb[i][j]=='B')return 1;
                 else if(cb[i][j]=='R')return -1;
             }
         }
     }
     return 0;
 }


 int Evaluate(char c){//evaluates current board state
    int e,v;
    v=e=0;
    for(int i=0;i<X;i++){
        for(int j = 0;j<Y;j++){
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

intt Max(int depth){
    intt val,best;
    if(depth<=0){
        best.score = Evaluate('B');
        return best;
    }

    for(int x=0;x<X;x++){
        int y=0;
        while(cb[x][y]=='x'||cb[x][y]=='u'&&ONBOARD(x,y))y++;
        val.x.x = x;
        val.x.y = y;
        if(ONBOARD(x,y)){
            MAKEM(val.x,'B')
            val = Min(depth-1);
            UNMAKEM(val.x)
            if(val.score>best.score)best=val;
        }
    }
    return best;
}

intt Min(int depth){
    intt val,best;
    if(depth<=0){
        best.score = Evaluate('B');
        return best;
    }

    for(int x=0;x<X;x++){
        int y=0;
        while(cb[x][y]=='x'||cb[x][y]=='u'&&y>Y)y++;
        val.x.x = x;
        val.x.y = y;
        if(ONBOARD(x,y)){
            MAKEM(val.x,'R')
            val = Min(depth-1);
            UNMAKEM(val.x)
            if(val.score<best.score)best=val;
        }
    }
    return best;
}

void startgame(c)
char *c;
{
    int t,w,r;
    if(!strcmp(c,"Red")){
        t=1;
    }
    else if(!strcmp(c,"Black")){
        t=0;
    }
    w=0;
    while(w==0){
        if(t%2==0){//black turn
            intt b = Max(5);
            if(ONBOARD(b.x.x,b.x.y))MAKEM(b.x,'B')
            printf("your turn ;)\n");
        }
        else{//red turn
            printf("where would you like to move\n");
            scanf("%d",&r);
            int y=0;
            while(cb[r][y]=='x'||cb[r][y]=='u'&&y>Y)y++;
            move m= {r,y};
            MAKEM(m,'R')
        }
        t++;
        pb();
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
else {printf("oh ok have a nice day \nint victor(char c); \\[T]// \n PRAISE THE SUN\n\n\n");}
*/
    
}