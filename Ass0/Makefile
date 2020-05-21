all: main

main: mainAssignment0.o asmAssignment0.o
	gcc -m32 mainAssignment0.o asmAssignment0.o -o main
	rm *.o
	./main 

mainAssignment0.o: mainAssignment0.c
	gcc -g -m32 -c -o mainAssignment0.o mainAssignment0.c 

asmAssignment0.o: asmAssignment0.s
	nasm -f elf32 asmAssignment0.s -o asmAssignment0.o

.PHONY: clean
clean: 
	rm -f *.o main