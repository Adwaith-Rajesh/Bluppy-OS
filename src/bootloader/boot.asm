org 0x7C00      ; set the offset
bits 16         ; use 16 bit compilation mode


%define ENDL 0x0D, 0x0A

;
; FAT 12 headers
;


jmp short start
nop


bpb_oem_identifier:             db 'MSWIN4.1'       ; 8 bits
bpb_bytes_per_sector:           dw 512
bpb_sectos_per_cluster:         db 1
bpb_reserved_sectors:           dw 2
bpb_fat_count:                  db 2
bpb_dir_entries_count:          dw 0E0h
bpb_sector_count:               dw 2880             ; 2880 * 512 = 1.44 MB
bpb_media_descriptor_type:      db 0F0h             ; 3.5' Floppy disk
bpb_sectors_per_fat:            dw 9                ; 9 sectors per FAT
bpb_sectors_per_track:          dw 18
bpb_heads:                      dw 2
bpb_hidden_sectors:             dd 0
bpb_large_sector_count:         dd 0


;
; Extended boot record
;

ebr_drive_number:               db 0                    ; 0x00 for a floppy disk and 0x80 for hard disks
                                db 0                    ; reserve bit
ebr_signature:                  db 29h
ebr_volume_id:                  db 12h, 34h, 56h, 78h   ; 4 bytes serial number, can be anything
ebr_voulme_label:               db 'BLUPPY   OS'        ; 11 bytes padded with spaces
ebr_system_id:                  db 'FAT12   '           ; 8 bytes padded with space



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
; prints a string to the terminal
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
