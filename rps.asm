BITS 16
ORG 0x7C00 ; location where mbr loads to

;clear screen
mov ax, 0x0003
int 0x10

;show name
mov si, message1
call print
mov si, message2
call print
jmp loop

; print subroutine
print:
    push ax ; store ax since it will be changed
    jmp print_main
print_main:
    lodsb ; basically load from si into al and si++
    cmp al, 0 ; check for null terminator
    je ret_print
    mov ah, 0x0E ; set teletype output
    int 0x10 ; call bios teletype
    jmp print_main
ret_print:
    pop ax ; return ax to og state and ret
    ret

loop:
    mov ax, 0x0040 ; get timer tick to generate random value
    mov ds, ax
    mov bx, [0x006C]
    xor dx, dx ; mod 3 to turn the value into 0-2 (0=rock 1=paper etc.)
    mov bx, 3
    div bx
    mov si, you_pick
    call print
    jmp check_key
check_key:
    mov ah, 0x00 ; bios read function
    int 0x16
    cmp al, '1' ; cmp keys
    je rock
    cmp al, '2'
    je paper
    cmp al, '3'
    je scissors
    jmp check_key ; jump back if none match
rock:
    mov si, rock
    call print
    mov si, i_picked
    call print
    call ai_pick
    cmp bx, 0 ; tie
    je tie
    cmp bx, 1 ; paper
    je i-won
    cmp bx, 2 ; scissors
    je you-won
paper:
    mov si, paper
    call print
    mov si, i_picked
    call print
    call ai_pick
    cmp bx, 0 ;win
    je you-won
    cmp bx, 1 ;tie
    je tie
    cmp bx, 2 ;loss
    je i-won
scissors:
    mov si, scissors
    call print
    

;print what the ai picked
ai_pick:
    cmp bx, 0 ;rock
    je ai_rock
    cmp bx, 1 ;paper
    je ai_paper
    cmp bx, 2 ; scissors
    je ai_scissors
ai_rock:
    mov si, rock
    call print
    ret
ai_paper:
    mov si, paper
    call print
    ret
ai_scissors:
    mov si, scissors
    call print
    ret

; values and strings (0x0D, 0x0A is newline)
message1 db "rock_paper_scissors_OS by flloatwer", 0x0D, 0x0A, 0
message2 db "press: 1-rock, 2-paper, 3-scissors", 0x0D, 0x0A, 0
you_pick db "you pick: ", 0
i_picked db "i picked: ", 0
you_won db "you won...", 0x0D, 0x0A, 0
i_won db "i won!", 0x0D, 0x0A, 0
we_tied db "we tied", 0x0D, 0x0A, 0
rock db "rock", 0x0D, 0x0A, 0
paper db "paper", 0x0D, 0x0A, 0
scissors db "scissors", 0x0D, 0x0A, 0

times 510 - ($ - $$) db 0 ; fill rest of bootsector with zeroes
dw 0xAA55 ; magic word that shows this is bootable