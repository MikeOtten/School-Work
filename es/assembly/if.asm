start:
	mov R0,#3;i
	mov R1,#5;j
	mov a,R0
	mov 17,r1
	cjne a,17,l1
	mov R2,#8;k
	jmp l2
l1:
	mov R2,#9;k
l2:
	jmp start