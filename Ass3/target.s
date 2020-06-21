; (*) call createTarget() function to create a new target with random coordinates on the game board
; (*) switch to the co-routine of the "current" drone by calling resume(drone id) function

; createTarget():
; (*) Generate a random x coordinate
; (*) Generate a random y coordinate
%macro	syscall1 2
    mov	    ebx, %2
    mov	    eax, %1
    int	    0x80
%endmacro

%macro	syscall3 4
    mov	    edx, %4
    mov	    ecx, %3
    mov	    ebx, %2
    mov	    eax, %1
    int	    0x80
%endmacro

%macro  exit 1
    syscall1 1, %1   ; 0 - no errors, -1 - with error
%endmacro

%macro  printOut 2
    pushad
    pushfd
    push    dword %1 ; 3rd arg, string pointer
    push    dword %2 ; 2nd arg, format string
    call    printf
    add     esp, 8
    popfd
    popad
%endmacro

section	.rodata
    scaleNum: dd 100
    ; locPrint:   db "X - %.2f y - %.2f ",0
    titlePrint:     db 10, "Target location-", 0, 10
    xPrint:         db "   X - ", 0
    yPrint:         db "   Y - ", 0
    ; startx:         db "Start X from here-",0 ,10
    ; starty:         db "Start Y from here-",0 ,10
section .data
section .bss
    xLoc:   resd 1
    yLoc:   resd 1
section .text
    extern format_d
    extern format_s
    extern format_f
    extern pformat_d
    extern pformat_s
    extern pformat_f
    extern random_print
    extern calcLFSRrandom
    extern scaleTo
    extern randomNum
    extern printf
    extern scale
    global runTarget
runTarget:
    push    ebp
    mov     ebp, esp
    pushad
    call    createTarget

    ;____ Print for debug ____
    printOut titlePrint, pformat_s
    printOut xPrint, format_s
    printOut [xLoc], pformat_d
    printOut yPrint, format_s
    printOut [yLoc], pformat_d
    mov     esp,ebp
    pop     ebp
    ret


createTarget:
    push    ebp
    mov     ebp, esp
    ; ____ Get Random X ___
    mov     [scale], dword 0
    call    calcLFSRrandom
    push    randomNum
    push    dword[scaleNum]
    call    scaleTo
    mov     eax, [scale]
    mov     [xLoc], eax
    
    ; ____ Get Random Y ___
    mov     [scale], dword 0
    call    calcLFSRrandom
    push    randomNum
    push    dword[scaleNum]
    call    scaleTo
    mov     eax, [scale]
    mov     [yLoc], eax
    mov     esp,ebp
    pop     ebp
    ret
