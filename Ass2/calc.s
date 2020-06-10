
%macro initialFunc 0
    pushad
    push ebp
    mov ebp, esp
    inc dword [counter]
%endmacro

%macro finishingFunc 0
    mov esp, ebp
    pop ebp
    popad
    jmp getInput
%endmacro
section .bss
    input: resb 80            ; input - max 80 bytes
    cleaninput: resb 80
    opStack: resb 5*4         ; operands stack
    opSp: resb 4              ; operands stack pointer
    nPTR: resb 4
    index: resb 4
section .data
    counter: dd 0           ; operation counter
section .rodata
    pCalc: db 'calc: ', 0
    pDebug: db 'DEBUG',10, 0
    nData: equ 0
    nNext: equ 1

section .text
  align 16
  global main
  extern printf
  extern fprintf
  extern fflush
  extern malloc
  extern calloc
  extern free
 ; extern gets
  extern getchar
  extern fgets
  extern stdin
main:
    push ebp
    mov ebp, esp
    mov [opSp], dword opStack ; initialize operand stack pointer
    pushad

getInput:

    push dword pCalc
    call printf
    add esp, 4                ; skip 1 param
    popad

    push dword [stdin]        ; get first argument
    push dword 80
    push dword input
    call fgets                ; return into eax \ input variable
    add esp, dword 12         ; ????????????????? WHAT THE HECK

    mov bl, byte [input]

    cmp bl,'q'                ; if input is quit
    je finish

    cmp bl,'+'                ; if input is addition
    jz addition

    cmp bl,'d'                ; if input is duplicate
    jz duplicate

    cmp bl,'p'                ; if input is pop and print
    jz popAndPrint

    cmp bl,'&'                ; if input bitwise and
    jz bitwiseAnd

    cmp bl,'|'                ; if input is or
    jz bitwiseOr

    cmp bl,'n'                ; if input number of hexadecimal digits
    jz numOfDigits

    cmp bl,'*'                ; if input is multipication
    jz multipiction

    ; if reached here, input is a number

isNum:
    push cleaninput
    push input
    call createLinkList
    mov ebx, [opSp]
    mov [ebx], eax
    add [opSp], dword 4
    jmp getInput


    createLinkList:
        initialFunc
        skipZeroes:
            mov ecx, [ebp + 8]
            mov bl, [ecx]
            cmp bl, 48
            jnz createLinks
            inc ecx
            jmp skipZeroes

        createLinks:
            nextlink: dd 0
        createLink:
            mov [ebp + 12], ecx
            pushad
            push dword 5
            call malloc
            add esp, 4         ;eax - pointer to link, ecx - clean input
            ;mov ebx, nPTR
            ;mov ebx, eax
            mov bl, [ebp + 12]     
            mov [eax + nData] , bl
            mov [eax + nNext] , dword nextlink
            mov [nextlink], eax
            mov ebx, [nPTR]
            mov [opSp] , ebx
            mov edx, opSp + 4
            mov [opSp] , edx 
            ;add [input],word 1

            ; push dword 5
            ; call malloc
            ; add esp, 4
            ; mov [nPTR], eax
            ; mov cx, input
            ; mov [nPTR + nData] , cx
            ; mov [nPTR + nNext] , dword 0
            ; mov ebx, [nPTR]
            ; mov [ opStack + 4 ] , ebx

            ; mov ebx, [opStack]
            ; mov [opSp] , ebx
            ; mov ebx, [nPTR]
            ; mov [opSp + nNext] , ebx

            finishingFunc




addition:
    initialFunc

    ; push dword pDebug
    ; call printf

    ; mov esp, [opSp]
    ; mov ebp, esp
    mov eax, [opSp]
    mov ebx, [opSp+4]
    add ebx, eax
    ;mov eax ,[ebx+nData]
    push ebx
    call printf
    push dword pDebug
    call printf
    finishingFunc
duplicate:
    initialFunc

    finishingFunc
popAndPrint:
    initialFunc

    finishingFunc

bitwiseAnd:
    initialFunc

    finishingFunc

bitwiseOr:
    initialFunc

    finishingFunc

numOfDigits:
    initialFunc

    finishingFunc


multipiction:
    initialFunc

    finishingFunc

emptyStackErr:

stackOverflowErr:

finish:
    ; popad
    mov esp, ebp
    pop ebp

    mov eax,1
    mov ebx,0
    mov ecx,0
    mov edx,0
    int 0x80



