; (*) start from i=0
; (*)if drone (i%N)+1 is active
;     (*) switch to the i’th drone co-routine
; (*) if i%K == 0 //time to print the game board
;     (*) switch to the printer co-routine
; (*) if (i/N)%R == 0 && i%N ==0 //R rounds have passed
;     (*) find M - the lowest number of targets destroyed, between all of the active drones
;     (*) "turn off" one of the drones that destroyed only M targets.
; (*) i++
; (*) if only one active drone is left
;     (*)print The Winner is drone: <id of the drone>
;     (*) stop the game (return to main() function or exit)
