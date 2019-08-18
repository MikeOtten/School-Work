BITS 16         ;boot loader
;MOSTART: db 0X666

start:
    mov ax,666h
    mov es,ax
    mov bx,0

            ;intterupt arguments
    mov dl,0       ;drive number
    mov dh,0       ;head number
    mov ch,0       ;track number
    mov cl,2       ;sector number
    mov al,1       ;number of sectors to transfer
    mov ah,0x2      ;function number

    int 0X13

    jmp 0x666
