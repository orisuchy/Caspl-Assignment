
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
    ;add esp, 4                      ;?????????????????WHAT THE HECK
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


createLink:
    mov ecx , input
    .newLine:                   ; conver asci input into numbers
        cmp byte [ecx], 0x10    ;check if we reached new line
        je .allocate
        sub [ecx], byte 0x48    ; asci to number : minus 48
        inc dword ecx           ;get next dword in input
        jmp .newLine
    
    .allocate:
        pushad
	    push dword 5            ;FIXME: can be another number, depends on argument
	    call malloc
        mov [nPTR], eax
	    add esp, 4              ; save size for dword
        mov [nPTR], byte [input]	    ; data = 0
	    mov [nPTR + nNext], dword 0 ; next = null
	    popad

        ;mov eax, [nPTR]
		
        mov dl, byte 0
        sub ecx, dword 2
        cmp ecx, input
        
        mov dl, byte[ecx]
        shl dl,4

        

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



