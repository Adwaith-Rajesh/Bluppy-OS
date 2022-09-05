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
bpb_sectors_per_cluster:        db 1
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
ebr_volume_label:               db 'BLUPPY   OS'        ; 11 bytes padded with spaces
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

    ; lets read smthng
    ; BIOS should set dl to the drive number
    mov [ebr_drive_number], dl
    mov ax, 1           ; lba = 1
    mov cl, 1           ; sectors = 1
    mov bx, 0x7E00      ; data should be after the bootloader
    call disk_read

    ; print hello world
    mov si, hello
    call puts

    cli                 ; clear all interrupt, so that cpu remain halted
    hlt

; ####### ERRORS #######
floppy_error:
    mov si, msg_read_failed
    call puts
    call reboot_after_key_press

reboot_after_key_press:
    mov ah, 0
    int 16h             ; wait for a key press
    jmp 0FFFFh:0        ; jmp to the beginning of the BIOS, reboot prolly

.halt:
    cli
    hlt

; puts
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

    mov ah, 0x0E    ; tty interrupt
    mov bh, 0       ; set the page number to 0
    int 0x10        ; call the video interrupt

    jmp .puts_loop

.done:
    pop bx          ; reset all the values
    pop ax
    pop si
    ret


; ####### Disk subroutines #######


; lba_to_chs
;   params:
;  - ax - LBA address
; returns
;  - cx [0-5 bits] - sector
;  - cx [6-15 bits] - cylinder
;  - dh - head

lba_to_chs:

    push ax
    push dx

    xor dx, dx                              ; dx = 0
    div word [bpb_sectors_per_track]        ; ax = LBA / sectors_per_track
                                            ; dx = LBA % sectors_per_track
    inc dx                                  ; dx = (LBA % sectors_per_track) + 1
    mov cx, dx                              ; cx = sectors

    xor dx, dx                              ; dx = 0
    div word [bpb_heads]                    ; ax = (LBA / sectors_per_track) / heads
                                            ; dx = (LBA / sectors_per_track) % heads
    mov dh, dl                              ; dh = head
    mov ch, al                              ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                               ; put the upper two bits of cylinder in cl

    pop ax
    mov dl, al                              ; restore dl
    pop ax

    ret


; disk_read
; read n sectors from the disk
; params
;   - ax - lba
;   - cl - number of sectors to read (128 max)
;   - dl - drive number
;   - es:bx - memory location to store the data

disk_read:

    push ax             ; save all the registers, we modify
    push bx
    push cx
    push dx
    push di

    push cx             ; store cl, lba_to_chs modifies it.
    call lba_to_chs
    pop ax              ; al = number of sectors to read

    mov ah, 02h

    mov di, 3           ; retry count, floppy disk's in the real world are
                        ; freakin' unreliable
.retry:
    pusha               ; save all the register, WDK what register the BIOS will modify
    stc                 ; some BIOS are shit and won't set it
    int 13h             ; cf = 0 on success

    jnc .done

    ; OOPS failed
    popa
    call disk_reset

    dec di
    test di, di         ; check di = 0
    jnz .retry

.fail:
    jmp floppy_error

.done:
    popa

    pop di              ; restore all the registers
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; disk_reset
; reset the disk controller
; params:
;   - dl: drive number
disk_reset:
    pusha
    mov ah, 0
    stc                 ; same reason as mentioned above
    int 13h

    jc floppy_error
    popa
    ret



hello:              db "Hello, World!", ENDL, 0
msg_read_failed:    db "Disk read failed", ENDL, 0

times 510 - ($ - $$) db 0       ; fill the rest with zeros
dw 0xAA55                       ; magic bootloader number
