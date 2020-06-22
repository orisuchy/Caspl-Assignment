; (*) print the game board according to the format described below
; (*) switch back to a scheduler co-routine

; format:
; x,y	                               ; this is the current target coordinates
; 1,x_1,y_1,α_1,speed_1,numOfDestroyedTargets_1    ; the first field is the drone id
; 2,x_2,y_2,α_2,speed_2,numOfDestroyedTargets_2    ; the fifth field is the number of targets destroyed by the drone
; …
; N,x_N,y_N,α_N,speed_N,numOfDestroyedTargets_N

%macro  printOut 2
    pushad
    pushfd
    push    dword %1                         ; 3rd arg, string pointer
    push    dword %2                         ; 2nd arg, format string
    call    printf
    add     esp, 8
    popfd
    popad
%endmacro

%macro fprintOut 1

%endmacro

section .rodata
    extern xLocT
    extern yLocT
    pLocation: db "%d, %d", 10 ,0

section .text
    extern printf
    global runPrinter

    runPrinter:
        push dword [yLocT]
        push dword [xLocT]
        push dword pLocation
        call printf
        add esp, 12

        ret