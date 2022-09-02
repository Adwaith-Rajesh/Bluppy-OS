org 0x7C00      ; set the offset
bits 16         ; use 16 bit compilation mode


%define ENDL 0x0D, 0x0A

start:
    jmp main

main:
    ; set up the data segments
    mov ax, 0
    mov ds, ax          ; ds cannot be set directly using an immediate
    mov es, ax

    ; setup the stack
    mov ss, ax
    mov sp, 0x7C00      ; set the stack pointer to the start of OS

    ; print hello world
    mov si, hello
    call puts

    cli                 ; clear all interrupt, so that cpu remain halted
    hlt

;
; prints a string to the string
; params:
;   - ds:si -> pointer to the string
;
puts:
    ; save all the registers we will modify
    push si
    push ax
    push bx

.puts_loop:
    lodsb           ; loads one character from si to al
    or al, al       ; jz is set if al = 0
    jz .done

    mov ah, 0x0E    ; tty interupt
    mov bh, 0       ; set the page number to 0
    int 0x10        ; call the video interrupt

    jmp .puts_loop

.done:
    pop bx          ; reset all the values
    pop ax
    pop si
    ret


hello:          db "Hello, World!", ENDL, 0

times 510 - ($ - $$) db 0       ; fill the rest with zeros
dw 0xAA55                       ; magic bootloader number
