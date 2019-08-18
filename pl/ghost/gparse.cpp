#include "gparse.h"
int main(void){
    gparse gparser;
}

void gparser::gparser(void)
{
    success = true;
    if (lexer.openFile()) {
       lexer.getChar();
	   nextToken = lexer.lex();
	   cout << "First token is: " << nextToken << "\n";

	//   mountain_biking(); // Call start symbol

	}
    else 
        success = false;
    if (success)
        cout <<" ▲\n◀ θ ▶\n ▼";
        
}


void gparser::~gparser(void)
{
}

useing namespace gparse

//<weapon> --> <type> 
void gparser::weapon(void){
    cout << "weapon" << endl;
    if(nextToken == kinetic || nextToken==energy || nextToken==power || nextToken==campaign || nextToken==mission){
        nextToken = glexer.lex();
        cout << "First token is: " << nextToken << "\n";
    }
    else{
        success = false;
        cout << "Weapon misfire\n";
    }
}

void gparser::guardian(void){
    cout << "guardian" << endl;
    //<guardian> --> "("<idf>, <idf>, <idf>")"
    if(nextToken=="(")
    {
        nextToken= glexer.lex();
        cout << "First token is: " << nextToken << "\n";
    }
    else{
        success = false;
        cout << "Guardian down";
    }
}

void gparser::armor(void){
    cout << "armor" << endl;
    //<armor> --> <type> <idf>
    if(nextToken == kinetic || nextToken==energy || nextToken==power || nextToken==campaign || nextToken==mission){
        nextToken = glexer.lex(); //check for type
        cout << "First token is: " << nextToken << "\n";
        nextToken = glexer.lex(); //check for idf
    }
    else{
        success = false;
        cout << "Breach in your armor";
    }
}

void gparser::grimoire(void){
    cout << "grimoire" << endl;
    //<grimoir> --> <type> <idf>
    if(nextToken == kinetic || nextToken==energy || nextToken==power || nextToken==campaign || nextToken==mission){
        nextToken = glexer.lex();
        cout << "First token is: " << nextToken << "\\n";
    }
    else{
        success = false;
        cout << "You activated my trap card!";
    }
}

/*void gparser::traveler(void){
    cout << "traveler" << endl;
    //<traveler> --> <lib>

}*/

/*void gparser::ability(void){
    cout << "ability" << endl;
    //<ability> --> <expression>
    if(nextToken == )
}*/

void gparser::engram(void){
    cout << "engram" << endl;
    //<engram> --> <type> <idf>, <type> <idf>
    if(nextToken == kinetic || nextToken==energy || nextToken==power || nextToken==campaign || nextToken==mission){
        nextToken = glexer.lex();
        cout << "First token is: " << nextToken << "\n";
        nextToken = glexer.lex();
        if(nextToken == kinetic || nextToken==energy || nextToken==power || nextToken==campaign || nextToken==mission){
            nextToken = glexer.lex();
            cout << "First token is: " << nextToken << "\n";
            nextToken = glexer.lex();
        }
    }
    else{
        success = false;
        cout << "Engram could not be decrypted";
    }
}

void gparser::kinetic(void){
    int isint = 1;
    cout << "kinetic" << endl;
    //<kinetic> --> <idf>
    nextToken = glexer.lex();
    cout << "First token is: " << nextToken << "\n";
    if(nextToken == "="){
        nextToken = glexer.lex();
        for(int i = 0; i<=nextToken.length(); i++)
        {
            if(nextToken[i] == ".")
            {
                cout << "Wrong type!!!!\n";
                isint = 0;
            }
        }
        if(isint == 0){
            success = false;
            cout << "Out of kinetic ammo";
        }
        }
    }
    else{
        success = false;
        cout << "Out of kinetic ammo";
    }
}

void gparser::energy(void){
    int isdouble = 0;
    cout << "energy" << endl;
    //<energy> --> <idf>
    nextToken = glexer.lex();
    cout << "First token is: " << nextToken << "\n";
    if(nextToken == "="){
        nextToken = glexer.lex();
        for(int i = 0; i<=nextToken.length(); i++)
        {
            if(nextToken[i] == ".")
            {
                isdouble = 1;
            }
        }
        if(isdouble == 0){
            success = false;
            cout << "Out of energy ammo";
        }
        }
    }
    else{
        success = false;
        cout << "Out of energy ammo";
    }
}

void gparser::power(void){
    int isfloat = 0;
    cout << "power" << endl;
    //<power> --> <idf>
    nextToken = glexer.lex();
    cout << "First token is: " << nextToken << "\n";
    if(nextToken == "="){
        nextToken = glexer.lex();
        for(int i = 0; i<=nextToken.length(); i++)
        {
            if(nextToken[i] == ".")
            {
                isfloat = 1;
            }
        }
        if(isfloat == 0){
            success = false;
            cout << "Out of power ammo";
        }
        }
    }
    else{
        success = false;
        cout << "Out of power ammo";
    }
}

void gparser::quest(void){
    cout << "quest" << endl;
    //<quest> --> <type>
    if(nextToken == kinetic || nextToken==energy || nextToken==power || nextToken==campaign || nextToken==mission){
        nextToken = glexer.lex();
        cout << "First token is: " << nextToken <<"\n";
        if(nextToken == "quest"){
            nextToken = glexer.lex();
        }
    }
    else{
        success = false;
        cout << "Quest failed";
    }
}

void gparser::hunter(void){
    cout << "hunter" << endl;
    //<hunter> --> "("<boolean>")"
    if(nextToken == "("){
        nextToken = glexer.lex();
        cout << "First token is: " << nextToken <<"\n";
        nextToken = glexer.lex();
        while(true){
            if(nextToken == "=" || nextToken == ">" || nextToken == "<"){
                break;
            }
            else if(nextToken == EOF){
                    cout << "End of file found prematurely";
            }
        }
        nextToken = glexer.lex();
        while(true){
            if(nextToken == ")")
            {
                break;
            }
        }
    }
    else{
        success = false;
        cout << "Cayde-6 is missing";
    }
}

void gparser::titan(void){
    cout << "titan" << endl;
    //<titan> --> <boolean>
    if(nextToken =="(")
    {
        nextToken = glexer.lex();
        cout << "First token is: " << nextToken << "\n";
        if(nextToken != NULL){
            nextToken = glexer.lex();
        }
    }
    else{
        success = false;
        cout << "Zavala is crushed"
    }
}

void gparser::warlock(void){
    cout << "warlock" << endl;
    //<warlock> --> "("<type> <idf>";"<boolean>";"<inc/dec>")"
    if(nextToken == "("){
        nextToken = glexer.lex();
        cout << "First token is: " << nextToken << "\n";
        if(nextToken == kinetic || nextToken==energy || nextToken==power || nextToken==campaign || nextToken==mission){
            nextToken = glexer.lex();
            nextToken = glexer.lex();
            if(nextToken == ";"){
                nextToken = glexer.lex();
                while(true){
                    nextToken = glexer.lex();
                    if(nextToken == "=" || nextToken == ">" || nextToken == "<"){
                        break;
                    }
                    nextToken = glexer.lex();
                }
                if(nextToken == ";"){
                    nextToken = glexer.lex();
                }
                while(true){
                    nextToken = glexer.lex();
                    if(nextToken == "++" || nextToken =="--"){
                        break;
                    }
                    nextToken = glexer.lex();
                }
                if(nextToken == ")"){
                    nextToken = glexer.lex();
                }
            }
        }
    }
    else{
        success = false;
        cout << "Ikora is lost";
    }
}

void gparser::commlink(void){
    cout << "commlink" << endl;
    //<commlink> --> """ """ || <idf>
    if(nextToken =="''"){
        nextToken = glexer.lex();
        cout << "First token is: " << nextToken << "\n";
    }
}

/*void gparser::campaign(void){
    cout << "campaign" << endl;

}*/

/*void gparser::mission(void){
    cout << "mission" << endl;

}*/