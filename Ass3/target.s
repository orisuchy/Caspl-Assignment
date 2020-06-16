; (*) call createTarget() function to create a new target with random coordinates on the game board
; (*) switch to the co-routine of the "current" drone by calling resume(drone id) function

; createTarget():
; (*) Generate a random x coordinate
; (*) Generate a random y coordinate
section	.rodata
section .data
section .bss
section .text
    global runTarget
    extern calcLFSRrandom
    

runTarget:
    push    ebp
    mov     ebp, esp
    pushad
    call    createTarget



createTarget: