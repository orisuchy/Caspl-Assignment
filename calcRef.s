%macro malloc_node 0
	pushad
	push dword NODE_SIZE
	call malloc
	add esp, 4 ; size of dword
	mov [eax+NEXT], dword 0 ; next = null
	mov [eax+DATA], byte 0	; data = 0
	mov [MALLOC_PTR], eax
	popad
%endmacro

%macro exception 1
	pushad
	push dword %1
	push dword [stderr]
	call fprintf
	add esp, 4
	pop ebp
	popad
%endmacro

%macro check_valid_operation_command 1
	cmp %1, byte NEW_LINE ; check if second byte of input is a newline
	je .ok
	exception _ILLEGAL_INPUT
	; uncount operation (this is not a valid operation command)
	dec dword [Counter]
	jmp read_input
	.ok:
%endmacro

section .rodata
ASCII_FIX:	equ 48
NEW_LINE:	equ 10
DATA:	equ 0
NEXT:	equ 1

STACK_SIZE: 	equ 5
NODE_SIZE: 	equ 5
IN_BUF_SIZE: 	equ 80

prompt: 		db 'calc: ', 0
_STACK_OVERFLOW: 	db 'Error: Stack is already full', NEW_LINE, 0
_INSUFFICIENT_ARGS: 	db 'Error: Insufficient Arguments!', NEW_LINE, 0
_OPERAND_OVERFLOW: 	db 'Error: Operand Stack Overflow', NEW_LINE, 0
_ILLEGAL_INPUT:		db 'Error: Illegal Input', NEW_LINE, 0

section .bss
_STACK_:	RESB STACK_SIZE*4
_SP_: 		RESB 4
IN_BUFFER: 	RESB 80
Counter: 	RESB 4
PREVIOUS_NODE: 	RESB 4
MALLOC_PTR: 	RESB 4
CARRY:		RESB 1
NEW_CARRY:	RESB 1

section .text
     align 16
     global main
     
     extern printf
     extern fprintf
     extern fgets
     
     extern malloc
     extern free
     
     extern stderr
     extern stdin
     extern stdout 
     
main:
	push ebp
	mov ebp, esp
	
	mov [_SP_], dword _STACK_
read_input:
	; print prompt
	pushad
	push dword prompt
	call printf
	add esp, 4
	popad
	
	; read input to eax
	push dword [stdin]
	push dword IN_BUF_SIZE
	push dword IN_BUFFER
	call fgets
	add esp, dword 12
	
	mov bl, byte [eax]
	
	; check if input is the quit command
	cmp_q:
	cmp bl, 'q'
	jne .cond_input
	check_valid_operation_command [eax+1]
	jmp f_quit
	
	.cond_input:
	inc dword [Counter] ; count operation in advance
	
	cmp_add:
	cmp bl, '+'
	jne cmp_p
	check_valid_operation_command [eax+1]
	call f_add
	jmp read_input
	
	
	cmp_p:
	cmp bl, 'p'
	jne cmp_d
	check_valid_operation_command [eax+1]
	call f_pop_and_print
	jmp read_input
	
	cmp_d:
	cmp bl, 'd'
	jne cmp_and
	check_valid_operation_command [eax+1]
	call f_duplicate
	jmp read_input
	
	cmp_and:
	cmp bl, '&'
	jne not_an_op
	check_valid_operation_command [eax+1]
	call f_and
	jmp read_input
	
	not_an_op:
	; uncount operation (this is a number, not an operation)
	dec dword [Counter]
	
	.validate_input:
	mov ecx, eax ; ecx = &input
	; check if input is empty
	cmp [ecx], byte NEW_LINE
	jne .input_loop
	exception _ILLEGAL_INPUT
	jmp read_input
	
	.input_loop:
	mov bl, [ecx]
	cmp bl, NEW_LINE
	je .input_valid
	
	cmp bl, 0 + ASCII_FIX
	jge .not_below
	exception _ILLEGAL_INPUT
	jmp read_input
	.not_below:
	
	cmp bl, 9 + ASCII_FIX
	jle .not_above
	exception _ILLEGAL_INPUT
	jmp read_input
	.not_above:
	
	inc dword ecx ; ecx++
	jmp .input_loop
	.input_valid:
	
check_overflow:
	cmp [_SP_], dword _STACK_+STACK_SIZE*4 ;_STACK_[STACK_SIZE*sizeof(void *)]
	jl .not_overflow
	;; output exception
	pushad
	push dword _STACK_OVERFLOW
	push dword [stderr]
	call fprintf
	add esp, 4
	pop ebp
	popad
	jmp read_input
	.not_overflow:
	
allocate_bytes:

	mov ecx, IN_BUFFER
    find_newline:
	;; find the end of the input while converting from ascii
	cmp byte [ecx], NEW_LINE ; reached new-line?
	je build_nodes
	;print_log
	sub [ecx], byte ASCII_FIX
	inc dword ecx
	jmp find_newline
	
    build_nodes:
	.initialize:
	mov [PREVIOUS_NODE], dword 0
	
	.build_loop:
	malloc_node
	mov eax, [MALLOC_PTR]
	
	; put byte in allocated memory
	mov dl, byte 0
	sub ecx, dword 2
	cmp ecx, IN_BUFFER
	jl .odd
	mov dl, byte [ecx]
	shl dl, 4
	.odd:
	add dl, byte [ecx+1]
	mov [eax], byte dl
	.b1:
	; put the current node as next of previous node
	mov edx, dword [PREVIOUS_NODE]
	cmp edx, dword 0
	jne .not_first
	
	; push the first node to the virtual stack
	.b2:
	mov ebx, dword [_SP_]
	mov [ebx], dword eax
	add ebx, dword 4 ; size of pointer
	mov [_SP_], dword ebx ; update _SP_
	jmp .finish_round
	
	.not_first:
	mov [edx+1], dword eax
	
	.finish_round:
	; set PREVIOUS_NODE to be the current node for the next round
	mov [PREVIOUS_NODE], dword eax
	; check if there more bytes to put in nodes
	cmp ecx, IN_BUFFER
	jg .build_loop
	; finished, jump to start
	jmp read_input
	
f_add:
	pushad ; save state
	push ebp
	mov ebp, esp
	
	mov edx, dword [_SP_]
	cmp edx, dword _STACK_+8
	jge .args_exist
	exception _INSUFFICIENT_ARGS
	dec dword [Counter]
	jmp .insuff
	.args_exist:
	
		;; remove the top number, write the sum into the bottom one
		; update the stack pointer
		sub edx, dword 4 
		mov [_SP_], dword edx
		
		; retrieve pointers
		mov ebx, dword [edx-4]
		mov ecx, dword [edx]
		
		; reset CARRY
		mov [CARRY], byte 0
	
	.add_loop:
		;; NEW_CARRY is the carry calculated in this round
		;; CARRY is from the last round
		mov al, byte [ebx+DATA]
		add al, byte [ecx+DATA]
		daa			; fix bits of binary-coded decimal
		; calculate carry
		jnc .no_carry
		mov [NEW_CARRY], byte 1
	.no_carry:
	
		add al, byte [CARRY]
		daa 			; fix bits of binary-coded decimal
		; calculate carry
		jnc .no_late_carry
		mov [NEW_CARRY], byte 1
	.no_late_carry:
	
		mov [ebx+DATA], byte al ; update node data
		
		; update carries for the next round
		mov al, byte [NEW_CARRY]
		mov [CARRY], byte al
		mov [NEW_CARRY], byte 0
		
		mov edx, ebx 	; backup ebx
		mov ebx, dword [ebx+NEXT]
		mov ecx, dword [ecx+NEXT]
			pushad
		push ebp
		mov ebp, esp
		; check if one of the numbers has still not ended
		mov eax, ebx
		and eax, ecx
		cmp eax, dword 0
		jne .add_loop 	; both number didn't end, keep going
	.end_loop:
	
	.carry_stuff_again:
		mov eax, ebx
		or eax, ebx
		cmp eax, 0
		jne .dont_do_it
		mov ebx, edx 	; retrieve backup
		; if carry is not 0 and the numbers has both ended
		; then we need to create a new node to hold the carry 
		cmp [CARRY], byte 0
		je .dont_do_it
		mov [CARRY], byte 0
		malloc_node
		mov eax, dword [MALLOC_PTR]
		mov [ebx+NEXT], dword eax
		mov ebx, dword [ebx+NEXT]
		mov [ebx+DATA], byte 1
		jmp .finish
	.dont_do_it:
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		cmp ebx, dword 0
		jne .ebx_not_null
		mov ebx, edx	; rerieve backup
	.ebx_not_null:
		
		cmp ecx, dword 0
		jne .top_check_finish
		jmp .bottom_loop_carry
	.top_check_finish:
	
		cmp [ebx+NEXT], dword 0
		jne .finish
		; bottom.next=top.next
		mov edx, dword [ecx+NEXT]
		mov dword [ebx+NEXT], edx
		; top.next=null
		mov [ecx+NEXT], dword 0
		
	.bottom_loop_carry:
		cmp [CARRY], byte 0
		je .finish
		
		mov [CARRY], byte 0 	; reset carry
		
		mov al, byte 1
		add al, byte [ebx+DATA]
		daa
		jnc .no_overflow
		mov [CARRY], byte 1	; set carry
	.no_overflow:
	
		mov [ebx+DATA], byte al	; update node data
		
	.keep_loop:
		cmp [CARRY], byte 0
		je .finish
		
		cmp [ebx+NEXT], dword 0
		jne .no_allocation
		malloc_node
		mov eax, dword [MALLOC_PTR]
		mov [ebx+NEXT], dword eax
	.no_allocation:
	
		mov ebx, dword [ebx+NEXT]
		jmp .bottom_loop_carry
	
	.finish:
		mov ecx, dword [_SP_]
		mov ecx, [ecx]
		call free_nodes_in_ecx
	
	.insuff:
		mov esp, ebp
		pop ebp
		popad ; retrieve state
		ret
f_pop_and_print:
	;; eax is pointer
	;; bx is holder for the bytes we read
	;; cl is holder
	
	; save state
	pushad
	push ebp
	mov ebp, esp
	
	; initialize
	mov ecx, dword 0
	mov ebx, dword 0
	mov eax, dword [_SP_]
	
	; exception check
	cmp eax, _STACK_
	jne .stack_not_empty
	exception _INSUFFICIENT_ARGS
	dec dword [Counter]
	mov esp, ebp
	pop ebp
	popad
	ret
	
	; null termination and new-line for printf
	.stack_not_empty:
	sub eax, 4	; the last value in the stack
	mov eax, [eax]	; is a pointer to the first node of the last number
	.push_null:
	sub esp, 1
	mov [esp], byte 0  ; null termination
	sub esp, 1
	mov [esp], byte NEW_LINE
	
	; main loop
	.push_loop:
	cmp eax, dword 0
	je .printf
	
	; loop body
	mov bx, word 0 		; clean bx
	mov bl, byte [eax+DATA]
	shl bx, 4 		; disassemble nibbles to bytes
	shr bl, 4 		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov cl, bl		; switch between
	mov bl, bh		; bh and bl
	mov bh, cl		;;;;;;;;;;;;;;
	
	add bl, byte ASCII_FIX
	add bh, byte ASCII_FIX
	sub esp, 2 		; leave space on the stack for 2 bytes
	mov [esp], word bx 	; push them bytes on the stack
	
	mov eax, [eax+1] 	; eax = next
	jmp .push_loop
	
	.printf:
	; remove leading zero for odd lengths
	cmp [esp], byte ASCII_FIX
	jne .even_length
	inc dword esp
	
	.even_length:
	push esp
	call printf
	
	.finish:
	; remove pointer from virtual stack
	sub [_SP_], dword 4
	
	; retrieve stack registers
	mov esp, ebp
	pop ebp
	
	; free memory
	mov ecx, dword [_SP_]
	mov ecx, dword [ecx]
	call free_nodes_in_ecx
	
	; retrieve state and return
	popad
	ret
	
f_duplicate:
	pushad ; save state
	push ebp
	mov ebp, esp
	
	mov eax, dword [_SP_]
	
	; overflow check
	.overflow_check:
	cmp eax, _STACK_+STACK_SIZE*4
	jl .insuff_check
	exception _OPERAND_OVERFLOW
	dec dword [Counter]
	jmp .return
	
	; insuff check
	.insuff_check:
	cmp eax, _STACK_
	jne .stack_not_empty
	exception _INSUFFICIENT_ARGS
	dec dword [Counter]
	jmp .return
	
	.stack_not_empty:
	;; malloc first node and update stack pointer
	malloc_node
	mov ebx, [MALLOC_PTR]
	mov [eax], dword ebx
	mov eax, [eax-4]
	add [_SP_], dword 4
	
	.loop_head:
	cmp eax, dword 0
	je .finish
	mov dl, byte [eax+DATA]
	mov [ebx+DATA], byte dl
	mov eax, dword [eax+NEXT]
	cmp eax, dword 0
	je .finish
	malloc_node
	mov ecx, dword [MALLOC_PTR]
	mov [ebx+NEXT], dword ecx
	mov ebx, ecx
	jmp .loop_head
	
	.finish:
	mov [ebx+NEXT], dword 0 ; set next=null
	
	.return:
	mov esp, ebp
	pop ebp
	popad ; retrieve state
	ret
	
f_and:
	pushad ; save state
	
	mov eax, [_SP_]
	cmp eax, _STACK_+8
	jge .init
	exception _INSUFFICIENT_ARGS
	dec dword [Counter]
	jmp .finish
	
	.init:
	sub [_SP_], dword 4
	
	mov eax, dword [_SP_]
	mov ebx, dword eax
	
	mov eax, dword [eax-4]
	mov ebx, dword [ebx]
	
	.loop_head:
	mov cl, byte [ebx]
	and byte [eax], cl
	mov edx, eax 		  ; backup eax
	mov eax, dword [eax+NEXT] ; eax = next
	mov ebx, dword [ebx+NEXT] ; ebx = next
	cmp eax, dword 0
	je .free_mem 		  ; finished :)
	cmp ebx, dword 0
	jne .loop_head		  ; both aren't 0, keep going
	
	;; ebx has zeros from now, so we remove the rest of eax
	mov [edx+NEXT], dword 0   ; next = null
	mov ecx, eax
	call free_nodes_in_ecx
	
	.free_mem:
	mov ecx, dword [_SP_]
	mov ecx, [ecx]
	call free_nodes_in_ecx
	
	.finish:
	popad ; retrieve state
	ret
	
;f_bits:
;; pops a number from the stack and prints it's bits
;; not in the specification...
;; ...I worked for nothing :(
;
;	pushad ; save state
;	push ebp
;	mov ebp, esp
;	
;	sub [_SP_], dword 4
;	mov eax, dword [_SP_]
;	mov eax, dword [eax]
;	
;	.push_null:
;	sub esp, 1
;	mov [esp], byte 0  ; null termination
;	sub esp, 1
;	mov [esp], byte NEW_LINE
;	
;	.loop_init:
;	cmp eax, dword 0
;	je .printf
;	
;	mov bl, byte [eax]
;	mov ecx, dword 8 ; loop counter for bits iteration
;	
;	.loop_head:
;	mov bh, bl
;	and bh, 1 	; 0000 0001
;	add bh, byte ASCII_FIX
;	sub esp, dword 1
;	mov [esp], byte bh
;	shr bl, 1
;	dec dword ecx
;	cmp ecx, dword 0
;	jg .loop_head
;	
;	mov eax, dword [eax+NEXT] ; eax = next
;	jmp .loop_init
;	
;	.printf:
;	push esp
;	call printf
;	
;	.free_mem:
;	mov ecx, dword [_SP_]
;	mov ecx, [ecx]
;	call free_nodes_in_ecx
;	
;	.finish:
;	mov esp, ebp
;	pop ebp
;	popad ; retrieve state
;	ret

free_nodes_in_ecx:

	pushad ; save state
	push ebp
	mov ebp, esp
	
	.start:
	cmp ecx, 0
	je .finish
	mov eax, ecx
	mov ecx, dword [ecx+NEXT]
	push ecx 	; backup ecx
	push eax	; push argument
	call free	; maliciously detroy my registers
	add esp, dword 4; cleanup
	pop ecx 	; retrieve ecx
	jmp .start
	.finish:
	
	mov esp, ebp
	pop ebp
	popad ; retrieve state
	ret
	
f_quit:
	; free remaining numbers in the virtual stack
	.loop_start:
	cmp [_SP_], dword _STACK_
	je .return
	; loop body
	sub [_SP_], dword 4
	mov eax, dword [_SP_]
	mov ecx, [eax]
	call free_nodes_in_ecx
	jmp .loop_start
	
	.return:
	mov eax, dword [Counter] ; return value
	mov esp, ebp
	pop ebp
	ret