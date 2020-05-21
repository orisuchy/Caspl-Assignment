section	.rodata                    ; we define (global) read-only variables in .rodata section
    format_string: db "%s", 10, 0  ; format string

section .bss                       ; we define (global) uninitialized variables in .bss section
    an: resb 12                    ; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]

section .text
    global convertor
    extern printf
	extern exit

convertor:
    push ebp
    mov ebp, esp
    pushad

	mov eax, 0
    mov ecx, dword [ebp+8]         ; get function argument (pointer to string)
                                   ; your code comes here:
    sub esp, 4
    mov [ebp-4], esp
    mov ebx, 0

prepareNumber:
    mov al, [ecx]                 
    cmp al, 'q'
    je exitOut
    cmp al, 10
    je preSTN
    sub al, 48
    push eax
    inc ecx                        ; TODO: check if right
    jmp prepareNumber

preSTN:
    mov ebx , 1                    ; mul
    mov ecx , 0                    ; decimal represantation

    stringToNum:
        pop eax                    ; take first num
        mul ebx                    ; multiplay by 10^location
        add ecx, eax               ; adding to final number - ebx
        mov eax, 10                ; next location
        mul ebx
        mov ebx, eax
        cmp esp, [ebp-4]           ; check if end of stack - explain to Ori
        je preHex
        jmp stringToNum            ; recursive for next number

preHex:
    mov ebx, 16                    ; divisor
    mov eax, ecx                    ; number presentation

    decToHex:
		cmp eax, 0                 ; check
		je preRev				   ;
        div ebx
        sub edx , 10               ; if number lower than 10 , sign will turn on
        js num
        add edx, 65                ; letter (A => 65 )
        push edx
		mov edx, 0
		mov ebx, 16 
        jmp decToHex
 
    num:
        add edx, 58                ; number (0 = >48)
        push edx
		mov edx, 0
        jmp decToHex

preRev:
    mov ebx, an
    cmp esp  ,[ebp-4] ; privae occasion ; num is o
    jne reverse
    mov ecx, 48
    push ecx

    reverse:
        pop ecx
        mov [ebx], ecx
        inc ebx
        cmp esp  ,[ebp-4]   ;reached end of the stack
        jne reverse

finish:
    push an                        ; call printf with 2 arguments -
    push format_string             ; pointer to str and pointer to format string
    call printf
    add esp, 12                     ; clean up stack after call

    popad
    mov esp, ebp
    pop ebp
    ret
exitOut:
	add esp, 8                     ; clean up stack after call
    popad
    mov esp, ebp
    pop ebp
	push eax
	call exit
	
