section	.rodata                          ; we define (global) read-only variables in .rodata section
    format_string: dd "%d"               ; format string

section .bss                             ; we define (global) uninitialized variables in .bss section
                                         ; an: resq 1                         ; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]


section .text
    global assFunc
    extern printf
    extern c_checkValidity

assFunc:                                 ; args:(int x, int y)
        push ebp
        mov ebp, esp
        pushad

        mov ecx, dword [ebp+8]           ; arg: x
        mov ebx, dword [ebp+12]          ; arg: y
                                         ; prepare c_checkValidity args
        push ebx
        push ecx
        mov eax, 0
        call c_checkValidity             ; return into eax
        cmp eax , 0
        jne ifOne                        ; if eax != 0, jump to ifOne(29)
        add ecx, ebx                     ; x=x+y
        jmp finish

ifOne:
        sub ecx, ebx                     ; x=x-y


finish:
        pop ebx                          ; clean up stack


    push ecx                             ; call printf with 2 arguments -
    push format_string                   ; pointer to str and pointer to format string
    call printf
    add esp, 8                           ; clean up stack after call

    pop ecx
    popad
    mov esp, ebp
    pop ebp
    ret


