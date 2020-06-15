; Your program should get the following command-line arguments (written in ASCII as usual, every argument is 4 bytes in size):

; N<int> – number of drones
; R<int> - number of full scheduler cycles between each elimination
; K<int> – how many drone steps between game board printings
; d<float> – maximum distance that allows to destroy a target
; seed<int> - seed for initialization of LFSR shift register

; > ass3 <N> <R> <K> <d> <seed>
; For example: > ass3 5 8 10 30 15019
%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro	syscall3 4
	mov	edx, %4
	mov	ecx, %3
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro  exit 1
	syscall1 1, %1 ; 0 - no errors, -1 - with error
%endmacro

%macro  scanNextTo 2
	pushad
    push    dword %1
    push    %2
    push    dword [ebx]
    call    sscanf
    add     esp, 12
    popad
    add     ebx, 4
%endmacro

%macro  printOut 2
	pushad
    pushfd
    push dword %1             ; 3rd arg, string pointer
    push dword %2             ; 2nd arg, format string
    call printf     
    add esp, 8
    popfd
    popad
%endmacro
section	.rodata
    format_d: db "%d", 10, 0
    format_s: db "%s", 10, 0
    format_f: db "%f", 10, 0
    
    here: db "here", 10, 0
    check: db "bla bla", 10, 0
section .bss
section .data
    numOfDrones: dd 0
    numOfcycles: dd 0
    stepsToPrint: dd 0
    maxDist: dd 0 ; TODO: need to be dt for floating point
    seed:dd 0
section .text
    global main
    extern printf
    extern fprintf
    extern sscanf
    extern malloc
    extern calloc
    extern free
    ;extern stdout
main:
    ; push ebp                        ;
    ; mov ebp, esp
    ; sub esp, 8 
    mov eax, [esp+4] ;argc
    mov ebx, [esp+8] ;argv <N> <R> <K> <d> <seed>
    cmp eax, 6h       ; verify num of args (5+1)
    jne exitErr
    add ebx, 4 ; skip a.out

    scanNextTo numOfDrones, format_d
    scanNextTo numOfcycles, format_d
    scanNextTo stepsToPrint, format_d
    scanNextTo maxDist, format_d ; TODO: need to be format_f for floating point
    scanNextTo seed, format_d
    ;Print to check - still have problem with float
    printOut [numOfDrones], format_d
    printOut [numOfcycles], format_d
    printOut [stepsToPrint], format_d
    printOut [maxDist], format_d ; TODO: need to be format_f for floating point
    printOut [seed], format_d
    exit 0

exitErr:
    exit -1    
