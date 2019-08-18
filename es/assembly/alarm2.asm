;setup
;the number to display
	mov	50h, #23 ;hours
    mov 51h, #59 ;min
    mov 52h, #00 ;sec
    mov 53h, #50h;first 2 digits POINTER HOURS/MIN DEFUALT

;30h-39h hold the 7seg bit patterns
	mov	30h, #11000000B
	mov	31h, #11111001B
	mov 32h, #10100100B
	mov	33h, #10110000B
	mov 34h, #10011001B
	mov	35h, #10010010B
	mov 36h, #10000010B
	mov 37h, #10000111B
	mov 38h, #10000000B
	mov 39h, #10011000B



start:
    ;check for buttion presses





    call calc
    call display
    jmp start

;display first 2 digits
display:
    mov acc,50h ;move number in to accumulater
	mov	b, #10  ;find 10's & 1's digit
	div ab
	mov	40h, acc  ;save 10's digit
	mov	41h, b  ;save 1's digit

	mov	r1, #40h ;digits[0]

    loop:  ;for each digit
        mov	acc, #30h
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
        cjne	r1, #43h, loop
        ret
    
