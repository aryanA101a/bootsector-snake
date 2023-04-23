;;SETUP
org 7C00h

jmp setup_game

;;CONSTANTS
VIDMEM = 0B800h ;video memory location in ram for vga text mode
SCREENW = 80
SCREENH = 25
WINCOND = 10
BGCOLOR = 03020h
APPLECOLOR = 4020h
SNAKECOLOR = 2020h
TIMER = 046Ch ;timer ticks handled in bios data area at this location in ram
SNAKEXARRAY = 1000h
SNAKEYARRAY = 2000h

;;VARIABLES
playerX: dw 40
playerY: dw 12
appleX: dw 16
appleY: dw 8
direction: db 4
snakeLength: dw 1


setup_game:
    ;;setup video mode
    mov ax,0003h ;vga text video mode
    int 10h ; invoke software interrupt to video services

    ;;setup video mem
    mov ax,VIDMEM
    mov es,ax ;es(extra space) is a segment register

    ;;setup snake head
    mov ax,[playerX]
    mov word [SNAKEXARRAY],ax
    mov ax,[playerY]
    mov word [SNAKEYARRAY],ax

game_loop:
    mov ax,BGCOLOR
    xor di,di
    mov cx,SCREENW*SCREENW
    rep stosw ;(mov es:di(destination index),ax and increase di) cx times


;; BOOTSECTOR PADDING
times 510 - ($-$$) db 0 ; fill in zeros 510-(current bytes-top byte) times
dw 0AA55h ;define magic number(for bootsector)