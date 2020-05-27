All:

All: calcExp.s
	nasm -f elf calcExp.s -ldList.lst  -o calcExp.o
	gcc -m32 -Wall -g calcExp.o -o calcExp
	rm -f ./*.o


.PHONY: clean
clean:
	rm -f calcExp dList.lst