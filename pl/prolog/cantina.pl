%FACTS
hired_gun(bodyguard).
hired_gun(marauder).
hired_gun(mercenary).
hired_gun(brawn).
    bodyguard(presence).
    marauder(inteligence).
    mercenary(cunning).

bounty_hunter(assasin).
bounty_hunter(gadgateer).
bounty_hunter(survivalist).
bounty_hunter(agility).
    assasin(presence).
    gadgateer(cunning).
    survivalist(willpower).

colonist(doctor).
colonist(politico).
colonist(scholor).
colonist(willpower).
    doctor(cunning).
    politico(brawn).
    scholor(agility).

explorer(scout).
explorer(trader).
explorer(fringer).
explorer(cunning).
    scout(presence).
    trader(willpower).
    fringer(brawn).

smuggler(pilot).
smuggler(scoundrel).
smuggler(thief).
smuggler(presence).
    pilot(cunning).
    scoundrel(willpower).
    thief(brawn).

technician(mechanic).
technician(outlaw_tech).
technician(slicer).
technician(inteligence).
    mechanic(presence).
    outlaw_tech(agility).
    slicer(brawn).



%RULES
hired_gun(B,A,I,W,C,P) :-
    B>A,B>I,B>W,B>C,B>P.

    bodyguard(B,A,I,W,C,P) :-
        hired_gun(B,A,I,W,C,P),P<A,P<I,P<W,P<C.
    marauder(B,A,I,W,C,P) :-
        hired_gun(B,A,I,W,C,P),I<A,I<P,I<W,I<C.
    mercenary(B,A,I,W,C,P) :-
        hired_gun(B,A,I,W,C,P),C<A,C<I,C<W,C<P.

    bodyguard(HIGH,LOW):-
        hired_gun(HIGH),bodyguard(LOW).
    marauder(HIGH,LOW):-
        marauder(HIGH),bodyguard(LOW).
    mercenary(HIGH,LOW):-
        mercenary(HIGH),bodyguard(LOW).

bounty_hunter(B,A,I,W,C,P) :-
    A>B,A>I,A>W,A>C,A>P.

    assasin(B,A,I,W,C,P) :-
        bounty_hunter(B,A,I,W,C,P),P<B,P<I,P<W,P<C.
    gadgateer(B,A,I,W,C,P) :-
        bounty_hunter(B,A,I,W,C,P),C<B,C<I,C<W,C<P.
    survivalist(B,A,I,W,C,P) :-
        bounty_hunter(B,A,I,W,C,P),W<B,W<I,W<P,W<C.

    assasin(HIGH,LOW):-
        bounty_hunter(HIGH),assasin(LOW).
    gadgateer(HIGH,LOW):-
        bounty_hunter(HIGH),gadgateer(LOW).
    survivalist(HIGH,LOW):-
        bounty_hunter(HIGH),survivalist(LOW).

colonist(B,A,I,W,C,P) :-
    W>A,W>I,W>B,W>C,W>P.

    doctor(B,A,I,W,C,P) :-
        colonist(B,A,I,W,C,P),C<B,C<A,C<I,C<P.
    politico(B,A,I,W,C,P) :-
        colonist(B,A,I,W,C,P),B<C,B<A,B<I,B<P.
    scholor(B,A,I,W,C,P) :-
        colonist(B,A,I,W,C,P),A<B,A<C,A<I,A<P.

    doctor(HIGH,LOW):-
        colonist(HIGH),doctor(LOW).
    politico(HIGH,LOW):-
        colonist(HIGH),politico(LOW).
    scholor(HIGH,LOW):-
        colonist(HIGH),scholor(LOW).

explorer(B,A,I,W,C,P) :-
    C>A,C>I,C>W,C>B,C>P.

    scout(B,A,I,W,C,P) :-
        explorer(B,A,I,W,C,P),P<B,P<A,P<I,P<W.
    trader(B,A,I,W,C,P) :-
        explorer(B,A,I,W,C,P),W<B,W<A,W<I,W<P.
    fringer(B,A,I,W,C,P) :-
        explorer(B,A,I,W,C,P),B<A,B<I,B<W,B<P.

    scout(HIGH,LOW):-
        explorer(HIGH),scout(LOW).
    trader(HIGH,LOW):-
        explorer(HIGH),trader(LOW).
    fringer(HIGH,LOW):-
        explorer(HIGH),fringer(LOW).

smuggler(B,A,I,W,C,P) :-
    P>A,P>I,P>W,P>B,P>C.

    pilot(B,A,I,W,C,P) :-
        smuggler(B,A,I,W,C,P),C<B,C<A,C<I,C<W.
    scoundrel(B,A,I,W,C,P) :-
        smuggler(B,A,I,W,C,P),W<B,W<A,W<I,W<C.
    thief(B,A,I,W,C,P) :-
        smuggler(B,A,I,W,C,P),B<C,B<A,B<I,B<W.

    pilot(HIGH,LOW):-
        smuggler(HIGH),pilot(LOW).
    scoundrel(HIGH,LOW):-
        smuggler(HIGH),scoundrel(LOW).
    thief(HIGH,LOW):-
        smuggler(HIGH),thief(LOW).

technician(B,A,I,W,C,P) :-
    I>A,I>B,I>W,I>C,I>P.

    mechanic(B,A,I,W,C,P) :-
        technician(B,A,I,W,C,P),P<B,P<A,P<W,P<C.
    outlaw_tech(B,A,I,W,C,P) :-
        technician(B,A,I,W,C,P),A<B,A<C,A<W,A<P.
    slicer(B,A,I,W,C,P) :-
        technician(B,A,I,W,C,P),B<C,B<A,B<W,B<P.
    
    mechanic(HIGH,LOW):-
        technician(HIGH),mechanic(LOW).
    outlaw_tech(HIGH,LOW):-
        technician(HIGH),outlaw_tech(LOW).
    slicer(HIGH,LOW):-
        technician(HIGH),slicer(LOW).