
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
    input: resb 80                  ; input - max 80 bytes
    opStack: resb 5*4               ; operands stack
    opSp: resb 4                    ; operands stack pointer
    counter: resb 4                 ; operation counter
    nPTR: resb 4
    index: resb 4
section .data

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
  extern gets
  extern getchar
  extern fgets
  extern stdin
main:
    push ebp
    mov ebp, esp
    mov [opSp], dword opStack       ; initialize operand stack pointer
    pushad

getInput:

    push dword pCalc
    call printf
    add esp, 4                      ;?????????????????WHAT THE HECK
    popad

    push dword [stdin]              ; get first argument
    push dword 80
    push dword input
    call fgets                      ; return into eax \ input variable
    add esp, dword 12              ;????????????????? WHAT THE HECK

    mov bl, byte [input]           ;

    cmp bl,'q'                     ;if input is quit
    jz finish

    cmp bl,'+'                     ;if input is addition
    jz addition

    cmp bl,'d'                    ;if input is duplicate
    jz duplicate

    cmp bl,'p'                    ; if input is pop and print
    jz popAndPrint

    cmp bl,'&'                    ; if input bitwise and
    jz bitwiseAnd
    
    cmp bl,'|'                    ; if input is or
    jz bitwiseOr

    cmp bl,'n'                    ; if input number of hexadecimal digits
    jz numOfDigits

    cmp bl,'*'                    ; if input is multipication
    jz multipiction
    
    ; if we reached here, input would be a number

createLinkedList:
    ; mov ecx, [input]
    ; mov eax ,0
    ; mov [index] , eax
    ; movToEnd:
    ;     mov ebx, [index]
    ;     add ebx, [input]
    ;     cmp byte[ebx], 0x10
    ;     jz createLink
    ;     sub byte[input], 0x48
        
    ;     inc byte input
    ;     ;inc [index]
    ;     jmp movToEnd
    createLink:
        push dword 5
        call malloc
        add esp, 4

        mov [nPTR], eax
        mov cx, input
        mov [nPTR + nData] , cx
        mov [nPTR + nNext] , dword 0
        mov [ opStack + 0] , [nPTR]
        inc input
        push dword 5
        call malloc
        add esp, 4

        mov nPTR, eax
        mov cx, input
        mov [nPTR + nData] , cx
        mov [nPTR + nNext] , dword 0
        mov [ opStack + 1] , [nPTR]
        mov [opSp] , [opStack]
        mov [opSp + nNext] , [nPTR]        

   
    

addition:
    initialFunc
    
    push dword pDebug
    call printf

    mov esp, [opSp]
    pop eax
    pop ebx
    add ebx, eax
    push ebx

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
    popad
    mov esp, ebp
    pop ebp

    mov eax,1
    mov ebx,0
    mov ecx,0
    mov edx,0
    int 0x80



