; (*) Generate random heading change angle  ∆α       ; generate a random number in range [-60,60] degrees, with 16 bit resolution
; (*) Generate random speed change ∆a         ; generate random number in range [-10,10], with 16 bit resolution        
; (*) Compute a new drone position as follows:
;     (*) first move speed units at the direction defined by the current angle, wrapping around the torus if needed.
;         For example, if speed=60 then move 60 units in the current direction.
;     (*) then change the current angle to be α + ∆α, keeping the angle between [0, 360] by wraparound if needed
;     (*) then change the current speed to be speed + ∆a, keeping the speed between [0, 100] by cutoff if needed
; (*) Do forever
;     (*) if mayDestroy(…) (check if a drone may destroy the target)
;         (*) destroy the target	
;         (*) resume target co-routine
;     (*) Generate random angle ∆α       ; generate a random number in range [-60,60] degrees, with 16 bit resolution
;     (*) Generate random speed change ∆a    ; generate random number in range [-10,10], with 16 bit resolution        
;     (*) Compute a new drone position as follows:
;         (*) first, move speed units at the direction defined by the current angle, wrapping around the torus if needed. 
;         (*) then change the new current angle to be α + ∆α, keeping the angle between [0, 360] by wraparound if needed
;         (*) then change the new current speed to be speed + ∆a, keeping the speed between [0, 100] by cutoff if needed
;     (*) resume scheduler co-routine by calling resume(scheduler)	
; (*) end do

section	.rodata
    angleScaleNum: dd 120
    speedScaleNum: dd 20

section .data
    angle: dd 0
    speed: dd 0

section .bss
    xLocD:   resq 1
    yLocD:   resq 1
section .text
    extern format_d
    extern format_s
    extern format_f
    extern pformat_d
    extern pformat_s
    extern pformat_f
    extern random_print
    extern calcLFSRrandom
    extern scaleTo
    extern randomNum
    extern printf
    extern scale
global runDrone

    runDrone:
        push    ebp
        mov     ebp, esp
        pushad

    ; Need to check all the Torus thing in the instructions
    calculateAngle:
        mov     [scale], dword 0
        call    calcLFSRrandom
        ; fild dword[randomNum]
        push    randomNum
        push    dword[angleScaleNum]
        call    scaleTo
        mov     eax, [scale]
        sub     eax, 60            ;[-60,60]
        mov     [angle], eax

    calculateSpeed:
        mov     [scale], dword 0
        call    calcLFSRrandom
        ; fild dword[randomNum]
        push    randomNum
        push    dword[speedScaleNum]
        call    scaleTo             ;[-10,10]
        mov     eax, [scale]
        sub     eax, 10
        mov     [speed], eax

    ; What about the initial loc????
    calculateNextLoc:
        nextXLoc:
            ; cos(alpha)*speed
        nextYLoc:
            ; sin(alpha)*speed


