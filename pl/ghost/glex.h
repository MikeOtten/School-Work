#pragma once

#include <stdio.h>
#include <string>
#include <iostream>
#include <fstream>
#include <map>

#define WEAPON 1
#define GUARDIAN 2
#define ARMOUR 3
#define GRIMOIRE 4
#define TRAVELER 5
#define ABILITY 6
#define ENGRAM 7
#define KINETIC 8
#define ENGERY 9
#define POWER  10
#define QUEST 11
#define HUNTER 12
#define TITAN 13
#define WARLOCK 14
#define COMMLINK 15
#define MISSION 16
#define PATROL 17

using namespace std;
class glex
{
    int charClass;
    char lexeme[100];
    char nextChar;
    int lexlen;
    int token
    int nextToken;
    ifstream file;
    map<string,int> specialWord
    public:
        Lexer(void);
		~Lexer(void);

		//Method declarations
		void addChar();
		void getChar();
		void getNonBlank();
		bool openFile();
		void closeFile();
		void fillSpecialWords();
		int lex();
		int lookup(char ch);

}