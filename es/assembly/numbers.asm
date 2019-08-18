start:
	mov 40h,#23        ;hours

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


;40h-41h hold the 3 digits to display
	mov	acc,40h
	mov	b, #10  ;find 10's & 1's digit
	div ab
	mov	40h, acc  ;save 10's digit
	mov	41h, b  ;save 1's digit

display:
	mov	r1, #40h ;digits[0]

loop:  ;for each digit
	mov	acc, #50h
	mov r3, acc  ;save acc;next blob:

;safe if you don't care about the
;bits of P3 other than p3.3 & p3.4
	mov	a, r1    ;picks which
	cpl a        ;7seg to use p3.3 &
	anl	a, #03h  ;p3.4 are a func
	rl	a        ;of the low2 bits of
	rl	a        ;the addr where the
	rl	a        ;digits live
	mov	p1, #0ffh;undraw previous
	mov	p3, a	 ;set new 7seg
	mov	a, r3    ;restore acc

; p1 = pattern[digit[i]] 
	add	a, @r1
	mov	r0, acc
	mov	p1, @r0
	inc	r1
;	mov	p1, #0ffh
	cjne	r1, #44h, loop
	jmp display

