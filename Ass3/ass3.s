; Your program should get the following command-line arguments (written in ASCII as usual, every argument is 4 bytes in size):

; N<int> – number of drones
; R<int> - number of full scheduler cycles between each elimination
; K<int> – how many drone steps between game board printings
; d<float> – maximum distance that allows to destroy a target
; seed<int> - seed for initialization of LFSR shift register

; > ass3 <N> <R> <K> <d> <seed>
; For example: > ass3 5 8 10 30 15019
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
    syscall1 1, %1                           ; 0 - no errors, -1 - with error
%endmacro

%macro  scanNextTo 2
    pushad
    push    %1
    push    %2
    push    dword[ebx]
    call    sscanf
    add     esp, 12
    popad
    add     ebx, 4
%endmacro

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

%macro initCoroutine 1
    mov     dword ebx, %1                    ; get Pointer to cor struct
    mov     dword eax, [ebx + corFuncOff]    ; get initial EIP value - pointer to CO function
    mov     dword [tempESP], esp             ; save esp value
    mov     esp, [ebx + corStackOff]         ; get initial ESP value – pointer to COi stack
    push    eax                              ; push return address
    pushfd                                   ; push flags
    pushad                                   ; push registers
    mov     [ebx + corStackOff], esp         ; save new SPi value
    mov     dword esp, [tempESP]
%endmacro

; getBit %2 = 16-bitNum(for SHR), %1 = 2^%2 (to get the bit with AND)
%macro getBit 2
    pushad
    mov     dword eax, 0
    mov     dword eax, [tempSeed]
    and     eax, %1
    shr     eax, %2
%endmacro


section	.rodata
    ; ____ Global Formats ____
    global format_d
    global format_s
    global format_f
    global pformat_d
    global pformat_s
    global pformat_f
    global random_print
    ; ____ Global Offsets ____
    global corFuncOff
    global corStackOff

    format_d:   db "%d", 0
    format_s:   db "%s", 0
    format_f:   db "%f", 0
    ; formats with "\n" for printing
    pformat_d:  db "%d", 10, 0
    pformat_s:  db "%s", 10, 0
    pformat_f:  db "%f", 10, 0
    ; pformat_position: db "%.2f,%.2f", 10, 0

    ; prints for debug
    random_print: db "Random Number - ",0
    next_bit:     db "next bit - "     ,0
    scaled_print: db "Scaled number - ",0
    corFuncOff  equ 0
    corStackOff equ 4

    stackSize   equ 16*1024                  ; 16 kb
section .bss
    printerStack:   resb stackSize
    targetStack:    resb stackSize
    schedulerStack: resb stackSize
    droneStack:     resb stackSize
    tempESP:        resd 1
    mainESP:        resd 1
    currCor:        resd 1
    ;scale:          resd 1

section .data
    ; ____ Global Vars ____
    global numOfDrones
    global numOfcycles
    global stepsToPrint
    global maxDist
    global randomNum
    ; ____ Global Co-routines ____
    global schedulerCor
    global printerCor
    global targetCor
    global droneCor

    extern runTarget
    global scale


    numOfDrones:    dd 0
    numOfcycles:    dd 0
    stepsToPrint:   dd 0
    maxDist:        dq 0.0                   ; TODO: need to be dt for floating point
    seed:           dd 0
    tempSeed:       dd 0
    seedChanger:    dd 1
    seed16bit:      dd 0
    seed14bit:      dd 0
    seed13bit:      dd 0
    seed11bit:      dd 0
    randomNum:      dd 0.0
    scale:          dq 0.0
    ; schedulerCor:   dd runScheduler
    ;                 dd schedulerStack + stackSize
    ; printerCor:     dd runPrinter
    ;                 dd printerStack + stackSize
    ; targetCor:      dd runTarget
    ;                 dd targetStack + stackSize
    ; droneCor:       dd runDrone
    ;                 dd droneStack + stackSize
    ; In scheduler???
    ; Cors:           dd schedulerCor
    ;                 dd printerCor
    ;                 dd targetCor
    ;                 dd droneCor
section .text
    extern printf
    extern fprintf
    extern sscanf
    extern malloc
    extern calloc
    extern free
    ; extern stdout
    ; ____ Global Functions ____
    global main
    global calcLFSRrandom
    global scaleTo
main:
    push    ebp
    mov     ebp, esp
    sub     esp, 4
    mov     eax, [ebp+8]                         ; argc
    mov     ebx, [ebp+12]                        ; argv <N> <R> <K> <d> <seed>
    ; cmp     eax, 6h                              ; verify num of args (5+1)
    ; jne     exitErr
    add     ebx, 4                               ; skip ./ass3
    ; ___________ Args to Variables ___________
    scanNextTo numOfDrones, format_d
    scanNextTo numOfcycles, format_d
    scanNextTo stepsToPrint, format_d
    scanNextTo maxDist, format_f             ; TODO: need to be format_f for floating point
    ; fld dword [maxDist]
    ; fstp qword [maxDist]
    scanNextTo seed, format_d
    mov     eax, [seed]
    mov     [tempSeed], eax
    

    call calcLFSRrandom
    ; ;_____ for debug ____
    printOut random_print, format_s
    printOut [randomNum], pformat_d
    
    push randomNum
    mov     dword eax,  100
    push    eax
    call scaleTo

    ; ; ;_____ for debug ____
    printOut scaled_print, format_s
    ;printOut [scale], pformat_f
    ;sub esp, 8
    fld dword [scale]
    fstp qword [esp]
    push pformat_f
    call printf
    add esp, 8
    call runTarget
    ; ___________ Print args for debug ___________
    ; printOut [numOfDrones], pformat_d
    ; printOut [numOfcycles], pformat_d
    ; printOut [stepsToPrint], pformat_d
    printOut [maxDist], pformat_f            ; TODO: need to be format_f for floating point
    ;sub esp, 8
    fld dword [maxDist]
    fstp qword [esp]
    push pformat_f
    call printf
    add esp, 8
    ; printOut [seed], pformat_d
    ; printOut [tempSeed], pformat_d

    ; printOut maxDist, pformat_d
    ; mov ebx, maxDist
    ; shl ebx, 15
    ; printOut ebx, pformat_f
    ; mov ecx, [maxDist]
    ; printOut ecx, pformat_f



    ; initCoroutine schedulerCor
    ; initCoroutine printerCor
    ; initCoroutine targetCor
    ; initCoroutine droneCor
    jmp exitNormal

    ; ===== Function To Calculate Random Number =====
calcLFSRrandom:
    push    ebp
    mov     ebp,esp
    sub     esp,4

    mov     ecx,0                            ; rounds counter to 15 (16 rounds)
    mov     dword [randomNum], 0
        randLoop:
        cmp     ecx, 16
        je randomReady
        ; ____ Get Bits From Seed ____
        ; getBit %2 = 16-bitNum (for SHR), %1 = 2^%2 (to get the bit with AND)
        getBit 1,0                           ; bit 16
        mov     dword[seed16bit], eax
        popad
        getBit 4,2                           ; bit 14
        mov     dword[seed14bit], eax
        popad
        getBit 8,3                           ; bit 13
        mov     dword[seed13bit], eax
        popad
        getBit 32,5                          ; bit 11
        mov     dword[seed11bit], eax
        popad

        ; _____ Xor Actions ____
        mov     dword eax, 0
        mov     dword ebx, 0
        mov     dword eax, [seed16bit]
        mov     dword ebx, [seed14bit]
        xor     eax, ebx
        mov     dword ebx, [seed13bit]
        xor     eax, ebx
        mov     dword ebx, [seed11bit]
        xor     eax, ebx

        ; ; print next bit for debug
        ; printOut next_bit, format_s
        ; printOut eax, pformat_d

        ; _____Add Bit To Random Number _____
        mov     ebx, 0
        mov     dword ebx, [randomNum]
        add     ebx, eax

        ; Print Random Number Status for debug
        ; printOut random_print, format_s
        ; printOut [randomNum], pformat_d

        shl     ebx, 1
        mov     dword[randomNum], ebx

        ; _____Arrange ROR _____
        mov     dword edx, 0
        mov     dword edx, [tempSeed]
        cmp     eax, 0
        jne     notZero
        mov     dword eax, 1                 ; eax = 0000..1
        not     eax                          ; eax = 1111..0
        and     edx, eax                     ; change last byte to 0
        jmp     readyToRor
        notZero:
        or      eax, edx                     ; change last byte to 1
        readyToRor:
        ror     edx, 1
        mov     [tempSeed], edx
        inc     ecx
        jmp     randLoop
        ; printOut [tempSeed], pformat_d
    randomReady:
        ; ___ Cancell Last Shift ___
        mov     ebx, 0
        mov     dword ebx, [randomNum]
        shr     ebx, 1
        mov     dword[randomNum], ebx
        ; use "seedChanger" to get better random
        mov     eax, [seed]
        add     eax, [seedChanger]
        mov     [tempSeed], eax
        inc     dword [seedChanger]
        mov     esp,ebp
        pop     ebp
        ret
scaleTo:
    ; To use need to push the number to scale and the scale measures
    push    ebp
    mov     ebp, esp
    mov     dword eax, [ebp+8]               ; scale measures
    mov     dword ebx, [ebp+12]              ; number to scale
    finit
    fld     dword [ebx]                      ; push float
    mov     dword [ebx], 0xffff              ; max int for 16bit
    fidiv   dword [ebx]                      ; number/ffff
    mov     dword [ebx], eax
    fimul   dword [ebx]                      ; (number/ffff) * scale
    fst     dword [scale]
    ; mov dword ecx, [ebp+8]
    ; mov dword eax, [ecx]
    mov     esp,ebp
    pop     ebp
    ret

droneCors:
    

    ; ===== Exits =====
exitNormal:
    exit 0

exitErr:
    exit -1
