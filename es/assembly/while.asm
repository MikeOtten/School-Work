start:
	mov R0,#64 ;a
	mov a,R0
l1:
	mov R1,a ;b
	djnz R0,l1
	
	jmp start