
section .bss
    input: resb 80     ; input - max 80 bytes
    opStack: resb 5*4  ; operands stack
    osp: resb 4        ; operands stack pointer
    counter: resb 4    ; operation counter
section .data


section .rodata
	pCalc: db 'calc: ', 0

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
    pushad

getInput:

    mov [osp], dword opStack ; initialize operand stack pointer

	push dword pCalc
	call printf
	;add esp, 4 WHAT THE HECK
	popad

    push dword [stdin] ; get first argument
    push dword 80
    push dword input
    call fgets         ; return into eax
	;add esp, dword 12 WHAT THE HECK

    mov bl,'q'
    cmp bl,input       ; if input is quit
    jz finish

    mov bl,'+'
    cmp bl,input       ; if input is addition
    jz addition

    mov bl,'d'
    cmp bl,input       ; if input is duplicate

    mov bl,'p'
    cmp bl,input       ; if input is pop and print
    jz popAndPrint

    mov bl,'&'
    cmp bl,input       ; if input bitwise and
    jz bitwiseAnd

    mov bl,'|'
    cmp bl,input       ; if input is or
    jz bitwiseOr

    mov bl,'n'
    cmp bl,input       ; if input number of hexadecimal digits
    jz numOfDigits

    mov bl,'*'
    cmp bl,input       ; if input is multipication
    jz multipiction

	mov esp, [osp]
	push input

    jmp getNum

addition:
	inc dword [counter]

duplicate:
	inc dword [counter]

popAndPrint:
	inc dword [counter]

bitwiseAnd:
	inc dword [counter]

bitwiseOr:
	inc dword [counter]

numOfDigits:
	inc dword [counter]

multipiction:
	inc dword [counter]

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



