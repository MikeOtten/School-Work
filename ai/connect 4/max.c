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
int Max(int depth) { 
    int best = -1;
    int val;

    if (depth<=0) return Evaluate('B');//eval black

    for(int x=0;x<7;x++){
        while(y<6&&cb[][])
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