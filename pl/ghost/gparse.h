#include "glex.h"

class gparser{
    glexer lexer;
    int nextToken;

public:
    gparser(void);
	~gParser(void);

    void weapon(void);
    void guardian(void);
    void armor(void);
    void grimoire(void);
    void traveler(void);
    void ability(void);
    void engram(void);
    void kinetic(void);
    void energy(void);
    void power(void);
    void quest(void);
    void hunter(void);
    void titan(void);
    void warlock(void);
    void commlink(void);
    void campaign(void);
    void mission(void);

        
    bool success;
};