 	mov 40h,#00        ;hours
 	mov 41h,#00        ;minutes
 	mov 42h,#00        ;seconds
	;43h are first and second digit holders
    move 43h,#40h
    ;44h if set final display gets the dot lit up
    move 44h,#00
    ;45,46,47,48 hold the 4 digits to be displayed

 	mov IE, #10000010b ;enamble interrupts & register handler for time
 	mov 50h,#11000000b ;zero
  	mov 51h,#11111001b ;one
  	mov 52h,#10100100b ;two
  	mov 53h,#10110000b ;three
  	mov 54h,#10011001b ;four
  	mov 55h,#10010010b ;five
  	mov 56h,#10000010b ;six
  	mov 57h,#11111000b ;seven
  	mov 58h,#10000000b ;eight
  	mov 59h,#10011000b ;nine
             
       	;counts up by seconds
  	mov R3,#0
  	mov TH0,#04ch
  	mov Tl0,#01h
  	mov tmod,#00000001b
  	mov tcon,#00010000b;1/20

start:
    mov 43h,#40h
    cjne p2.1,#0,hourmin;if set min/sec mode
    mov 43h,#41h
hourmin:;if set 12 hour mode
    call display
    jmp start

;//////////////////////////////////////////////////
display:
;mode select section
    cjne p2.0,#0,12hour ;if set 24 hour mode
    mov acc,40h
    mov 12,acc
    div ab
    cjne acc,1,pm
    mov 40h,b
    mov 44h,#1
pm:
12hour:
;math section
;45h-48h hold the 2 digits to display
    mov r0,43h
    mov acc,@r0
 	mov b, #10  ;find 10's & 1's digit
 	div ab
 	mov 45h, acc  ;save 10's digit
 	mov 46h, b  ;save 1's digit 

    cjne p2.0,#0,12hour2 ;if set 24 hour mode
    mov acc,40h
    add acc,#12
12hour2:
;display section     
 	mov r1, #45h ;digits[0]  
      loop:  ;for each digit
 	mov acc, #50h
 	mov r3, acc  ;save acc;next blob:
       
               ;safe if you don't care about the
               ;bits of P3 other than p3.3 & p3.4
 	mov a, r1      ;picks which
 	cpl a          ;7seg to use p3.3 &
 	anl a, #03h    ;p3.4 are a func
 	rl a           ;of the low2 bits of
 	rl a           ;the addr where the
 	rl a           ;digits live
 	mov p1, #0ffh  ;undraw previous
 	mov p3, a	     ;set new 7seg
 	mov a, r3     ;restore acc
     
      ;	p1 = pattern[digit[i]] 
 	add a, @r1
    cjne r1,47h,4thdigit
    cjne 44h,1,ampm
    subb a,#10000000b;
    mov 40h,#0
    4thdigit:
    ampm:
 	mov r0, acc
 	mov p1, @r0
 	inc r1
 	mov p1, #0ffh
 	cjne r1, #48h, loop
    ret
;//////////////////////////////////////////////
clock:
 	clr tf0
  	inc R3
  	cjne R3,#20,clockout
  	inc 42h
 	mov r0,#42h
clockup:
 	cjne @R0,#60,clockout
 	mov a,@R0
 	subb a,#60
 	mov @R0,a
 	cjne R0,#43h,clockup
clockout:
cjne 40h,#24,day
    mov 40h,#00
day:
  	reti
       
org 0bh
 	ljmp clock