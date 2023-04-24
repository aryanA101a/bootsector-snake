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
SNAKECOLOR = 7020h
TIMER = 046Ch ;timer ticks handled in bios data area at this location in ram
SNAKEXARRAY = 1000h
SNAKEYARRAY = 2000h
UP = 0
DOWN = 1
LEFT = 2
RIGHT = 3

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

    ;;hide cursor
    mov ah,02h ;set cursor position function code
    mov dx,2600h ;cursor position to set
    int 10h ;bios video dervices interrupt

game_loop:
    mov ax,BGCOLOR
    xor di,di
    mov cx,SCREENW*SCREENH
    rep stosw ;(mov es:di(destination index),ax and increase di) cx times

    ;;Draw snake
    xor bx,bx
    mov cx,[snakeLength]
    mov ax,SNAKECOLOR
    .snake_loop:
        imul di,[SNAKEYARRAY+bx],SCREENW*2
        imul dx,[SNAKEXARRAY+bx],2
        add di,dx
        stosw
        inc bx
        inc bx
    loop .snake_loop

    ;;Draw apple
    imul di,[appleY],SCREENW*2
    imul dx,[appleX],2
    add di,dx
    mov ax, APPLECOLOR
    stosw

    ;; Move snake in current direction
    mov al, [direction]
    cmp al,UP
    je move_up
    cmp al,DOWN
    je move_down
    cmp al,LEFT
    je move_left
    cmp al,RIGHT
    je move_right

    jmp update_snake_body

    move_up:
        dec word [playerY]
        jmp update_snake_body
    move_down:
        inc word [playerY]
        jmp update_snake_body
    move_left:
        dec word [playerX]
        jmp update_snake_body
    move_right:
        inc word [playerX]

    update_snake_body:
        ;;each cell is taking the place of its previous cell
        imul bx,[snakeLength],2
        .update_loop:
            mov ax,[SNAKEXARRAY-2+bx]
            mov word [SNAKEXARRAY+bx],ax
            mov ax,[SNAKEYARRAY-2+bx]
            mov word [SNAKEYARRAY+bx],ax

            dec bx
            dec bx
        jnz .update_loop 
    
    ;; Update head in the snake array
    mov ax,[playerX]
    mov word [SNAKEXARRAY],ax
    mov ax,[playerY]
    mov word [SNAKEYARRAY],ax

    ;; Lose conditions
    
    ;; 1. Borders
    cmp word[playerY], -1
    je game_lost
    cmp word[playerY], SCREENH
    je game_lost
    cmp word[playerX], -1
    je game_lost
    cmp word[playerX], SCREENW
    je game_lost

    ; 2. Snake body
    cmp word [snakeLength],1
    je get_player_input

    mov bx,2
    mov cx,[snakeLength]
    check_body_hit_loop:
        mov ax,[playerX]
        cmp ax, [SNAKEXARRAY+bx]
        jne .increment

        mov ax,[playerY]
        cmp ax,[SNAKEYARRAY+bx]
        je game_lost

        .increment:
            inc bx
            inc bx
    loop check_body_hit_loop



    get_player_input:
        mov bl,[direction]
        
        mov ah,1 ;ah<-1 to read a single keystroke
        int 16h ;bios software interrupt to start listening for keyboard input
        jz check_apple

        xor ah,ah
        int 16h ;on calling this interrupt the second time it stores the key pressed to al

        cmp al,'w'
        je w_pressed
        cmp al,'s'
        je s_pressed
        cmp al,'a'
        je a_pressed
        cmp al,'d'
        je d_pressed

        jmp check_apple

        w_pressed:
            mov bl,UP
            jmp check_apple
        s_pressed:
            mov bl,DOWN
            jmp check_apple
        a_pressed:
            mov bl,LEFT
            jmp check_apple
        d_pressed:
            mov bl,RIGHT
    
    check_apple:
        mov byte [direction],bl

        mov ax,[playerX]
        cmp ax,[appleX]
        jne delay_loop

        mov ax,[playerY]
        cmp ax,[appleY]
        jne delay_loop

        ;inc snake length
        inc word [snakeLength]
        cmp word [snakeLength],WINCOND ;check winning condition
        je game_won
    
    next_apple:
        ;; Random X position
        xor ah,ah
        int 1Ah ;timer ticks since midnight in cx:dx
        mov ax,dx
        xor dx,dx
        mov cx,SCREENW
        div cx ;ax/cx ax<-q dx<-r
        mov word [appleX],dx

        ;; Random Y position
        xor ah,ah
        int 1Ah
        mov ax,dx
        xor dx,dx
        mov cx,SCREENH
        div cx ;ax/cx ax<-q dx<-r
        mov word [appleY],dx
    
    ;;Apple inside snake
    xor bx,bx
    mov cx,[snakeLength]
    .check_loop:
        mov ax,[appleX]
        cmp ax,[SNAKEXARRAY+bx]
        jne .increment

        mov ax,[appleY]
        cmp ax,[SNAKEYARRAY+bx]
        je next_apple

        .increment:
            inc bx
            inc bx
    loop .check_loop

    delay_loop:
        mov bx,[TIMER]
        inc bx
        inc bx

        .delay:
            cmp [TIMER],bx
            jl .delay



jmp game_loop

;; End Conditions
game_won:
    mov dword [ES:07ceh],0a249a257h
    mov dword [ES:07d2h],0a221a24eh
    jmp reset

game_lost:
    mov dword [ES:07ceh],0c44Fc44Ch
    mov dword [ES:07d2h],0c445c453h

reset:
    xor ah,ah
    int 16h

    jmp 0FFFFh:0000h ;warm reboot 

;; BOOTSECTOR PADDING
times 510 - ($-$$) db 0 ; fill in zeros 510-(current bytes-top byte) times
dw 0AA55h ;define magic number(for bootsector)