	BITS 16                         ;drive h on the test pc on 172.16.52.29
									;nasm -o m m.asm
start:
	mov ax, 666h					;offset value		
	add ax, 288		
	mov ss, ax
	mov sp, 4096

	mov ax, 666h		            ; Set data segment to where we're loaded
	mov ds, ax

    mov      si,  prompt	
	call       showit	            ;printf prompt
                                    ; while (1) {}
	jmp $			                ;$ == here, just like 8051

prompt:   db       'Ottenating System', 0

showit:			 
	mov ah, 0Eh		                ; int 10h 'print char' function

.loop:
	lodsb			                ; load single byte (into AL),  for-loops through the array SI
	cmp      al, 0
	je          .done		        ;null = fnished 
	int         10h	                ; print it
	jmp      .loop

.done:
	ret

