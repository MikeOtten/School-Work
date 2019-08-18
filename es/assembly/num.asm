start:
	mov 40h,#155
;11 first 10 second 01 third 00 4th
;r1 is for the current digit
;100
	setb p3.3
	setb p3.4
	clr p3.3
	mov a,40h
	mov b,#100
	div ab
	mov R1,a
	call digits
;10
	setb p3.3
	clr p3.4
	mov a,b
	mov b,#10
	div ab
	mov R1,a
	call digits
;1
	clr p3.4
	clr p3.3
	mov R1,b
	call digits
	jmp start

digits:
	cjne R1,#0,l1
	jmp zero
l1:
	cjne R1,#1,l2
	jmp one
l2:
	cjne R1,#2,l3
	jmp two
l3:
	cjne R1,#3,l4
	jmp three
l4:
	cjne R1,#4,l5
	jmp four
l5:
	cjne R1,#5,l6
	jmp five
l6:
	cjne R1,#6,l7
	jmp six
l7:
	cjne R1,#7,l8
	jmp seven
l8:
	cjne R1,#8,l9
	jmp eight
l9:
	cjne R1,#9,digitse
	jmp nine
digitse:
	ret
delay:
	mov R0,#20
	djnz R0,$
	ret
zero:
	mov P1,#11000000b
	call delay
	mov p1,#11111111b
	ret
one:
	mov p1,#11111001b
	call delay
	mov p1,#11111111b
	ret
two:
	mov p1,#10100100b
	call delay
	mov p1,#11111111b
	ret
three:
	mov p1,#10110000b
	call delay
	mov p1,#11111111b
	ret
four:
	mov p1,#10011001b
	call delay  
	mov p1,#11111111b
	ret
five:
	mov p1,#10010010b
	call delay
	mov p1,#11111111b
	ret
six:
	mov p1,#10000010b
	call delay
	mov p1,#11111111b
	ret
seven:
	mov p1,#11111000b
	call delay
	mov p1,#11111111b
	ret
eight:
	mov p1,#10000000b
	call delay
	mov p1,#11111111b
	ret
nine:
	mov p1,#10011000b
	call delay
	mov p1,#11111111b
	ret