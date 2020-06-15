; Your program should get the following command-line arguments (written in ASCII as usual, every argument is 4 bytes in size):

; N<int> – number of drones
; R<int> - number of full scheduler cycles between each elimination
; K<int> – how many drone steps between game board printings
; d<float> – maximum distance that allows to destroy a target
; seed<int> - seed for initialization of LFSR shift register

; > ass3 <N> <R> <K> <d> <seed>
; For example: > ass3 5 8 10 30 15019

section	.rodata
section .bss
section .data
section .text
    global main
    extern printf
    extern fprintf
    extern sscanf
    extern malloc
    extern calloc
    extern free
main:
    
