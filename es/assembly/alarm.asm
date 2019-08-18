      ; registers in use:R0 R1 R3
      ; registers not in use :R5 R2 R4 R6 R7
 	mov 40h,#23        ;hours
 	mov 41h,#59        ;minutes
 	mov 42h,#00        ;seconds
	;43h and 44h are first and second digit holders

 	mov IE, #10000010b ;enamble interrupts & register handler for timer
	 
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
       
      	;watch for button presses
start:
	;jb p2.0,mode1;p2.0 0=12 hour 1=24 hour branches if 24 hour mode
	
mode1:
	;jb p2.1,mode2;p2.1 0=hours:min hour 1=min:sec branches if in min hour mode
	
mode2:
	
 	call display
 	jmp start
      	
display:       
      ;40h-41h hold the 3 digits to display
 	mov acc,40h
 	mov b, #10  ;find 10's & 1's digit
 	div ab
 	mov 40h, acc  ;save 10's digit
 	mov 41h, b  ;save 1's digit
       
 	mov r1, #40h ;digits[0]
      
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
 	mov r0, acc
 	mov p1, @r0
 	inc r1
 	mov p1, #0ffh
 	cjne r1, #44h, loop
 	jmp display
     
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
  	reti
       
org 0bh
 	ljmp clock