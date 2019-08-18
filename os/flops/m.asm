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
    call mash
                                    ; while (1) {}
	jmp $			                ;$ == here, just like 8051

prompt:   db       'Ottenating System', 0
prompto: db 		'Mash: ',0
prog:	db			'Programs: ',0
args: db 			'Arguments: ',0

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

read_print_loop:					;0dh = carrige return
    mov ah,0                        ;blocking read
    int 16h 						;read
    mov ah,0EH
    int 10h							;show char
    jmp read_print_loop

mash:
	mov ah,0EH
	mov al,0dh
	int 10h
	mov al,0ah
	int 10h
	mov al,07h
	int 10h
	mov BX,500h	;start of array at 500h
	mov si, prompto
	call showit
.loops:
	mov ah,0                        ;blocking read
    int 16h 						;read
	cmp al,0dh
	je .nl
	cmp al,0ah
	je .nl
	mov [BX],al
	inc BX
    mov ah,0EH
    int 10h
	jmp .loops
.nl:								;20h = space
	mov al,0h
	mov [bx],al
	mov ah,0EH
	mov al,0dh
	int 10h
	mov al,0ah
	int 10h
	mov si, prog
	call showit
	mov bx,500h
.nloops:
	mov al,[BX]
	inc BX
	cmp al,20h
	je .argsc
	cmp al,0h
	je .donez
	int 10h
	jmp .nloops
.argsc:
	mov ah,0EH
	mov al,0dh
	int 10h
	mov al,0ah
	int 10h
	mov si,args
	call showit
.argloop:
	mov al,[BX]
	inc BX
	cmp al,0h
	je .donez
	cmp al,20h
	je .argsc
	int 10h
	jmp .argloop
.donez:
	jmp mash




	
	