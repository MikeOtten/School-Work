#include "glex.h"
using namespace glex;

Lexer(void){
    fillSpecialWords();
}
~Lexer(void){
    closeFile();
}

bool openFile(){
    file.open("input.txt");
    if(!file.is_open()){
        printf("ERROR 404 FILE NOT FOUND\n");
        return false;
    }
    return true;
}
void closeFile(){
    file.close();
}

void fillSpecialWords(){
    cout << "gonna fill this sucker up\n";

    specialWord[string("Weapon")] =  1;
    specialWord[string("Guardian")] =  2;
    specialWord[string("Armour")] =  3;
    specialWord[string("Grimoire")] =  4;
    specialWord[string("Traveler")] =  5;
    specialWord[string("Ability")] =  6;
    specialWord[string("Engram")] =  7;
    specialWord[string("Kinetic")] =  8;
    specialWord[string("Engery")] =  9;
    specialWord[string("Power")] =   10;
    specialWord[string("Quest")] =  11;
    specialWord[string("Hunter")] =  12;
    specialWord[string("Titan")] =  13;
    specialWord[string("Warlock")] =  14;
    specialWord[string("Commlink")] =  15;
    specialWord[string("Mission")] =  16;
    specialWord[string("Patrol")] =  17;
}

int lookup(char ch){
    if (file.good()) {
		nextChar = file.get();
		//cout << "Next character:" << nextChar << "|" << endl;

		if (isalpha(nextChar)) 
			charClass = LETTER;		
		else if (isdigit(nextChar)) 
			charClass = DIGIT;	
		else if (nextChar == '_')
			charClass = UNDERSCORE;
		else 
			charClass = UNKNOWN;			
	}
	else {
            cout << "End of file reached.\n";
	 charClass = EOF;
        }
}

void addChar(){
    if (lexLen <= 98) {
		//cout << "Character " << nextChar << " placed at index " << lexLen << "\n";
		lexeme[lexLen++] = nextChar;
		lexeme[lexLen] = 0;
	}
	else 
		printf("Error - lexeme is too long \n");
}
void getChar(){
    if (file.good()) {
		nextChar = file.get();
		//cout << "Next character:" << nextChar << "|" << endl;

		if (isalpha(nextChar)) 
			charClass = LETTER;		
		else if (isdigit(nextChar)) 
			charClass = DIGIT;	
		else if (nextChar == '_')
			charClass = UNDERSCORE;
		else 
			charClass = UNKNOWN;			
	}
	else {
            cout << "End of file reached.\n";
	 charClass = EOF;
        }
}

void getNonBlank(){
    while (isspace(nextChar) && (charClass != EOF))
	getChar();
}

int lex(){
	cout << "LEX\n";
    
        lexLen = 0;
        getNonBlank();	// Eat up white space
    
        switch (charClass) {	
            //parse identifiers
            case LETTER:
                addChar();
                getChar();
                while (charClass == LETTER || charClass == DIGIT || charClass == UNDERSCORE) {
                    addChar();
                    getChar();
                }
                nextToken = specialWord[string(lexeme)];
                break;
            
            //parse ints
            case DIGIT:
                addChar();
                getChar();
                while (charClass == DIGIT) {
                    addChar();
                    getChar();
                }
                nextToken = INT_LIT;
                break;
            
            // Single characters
            case UNKNOWN:
                lookup(nextChar);
                getChar();
                break;
    
            case EOF:
                nextToken = EOF;
                lexeme[0] = 'E';
                lexeme[1] = 'O';
                lexeme[2] = 'F';
                lexeme[3] = 0;
                break;
        } //end of switch
    
        printf("lexeme: %s \n",lexeme);
        return nextToken;
}