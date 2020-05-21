all: main

main: task1As.o task1.o 
	gcc -m32 task1As.o task1.o -o main
	rm *.o
	./main 

task1.o: task1.c
	gcc -g -m32 -c -o task1.o task1.c 

task1As.o: task1.s
	nasm -f elf32 -o task1As.o task1.s

.PHONY: clean
clean: 
	rm -f *.o main