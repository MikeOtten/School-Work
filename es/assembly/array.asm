start:
	mov R0,#16 ;char array len = 64
	mov a,#0;i
l1:
	mov @R0,a
	inc R0
	inc a
	cjne a,#64,l1
	jmp start
