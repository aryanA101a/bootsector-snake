;;SETUP
org 7C00h

jmp setup_game

;;CONSTANTS

;;VARIABLES

;;LOGIC
setup_game:

;; BOOTSECTOR PADDING
times 510 - ($-$$) db 0 ; fill in zeros 510-(current bytes-top byte) times
dw 0AA55h ;define magic number(for bootsector)