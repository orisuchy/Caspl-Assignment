All:

All: calc.s
	nasm -f elf calc.s -ldList.lst  -o calc.o
	gcc -m32 -Wall -g calc.o -o calc
	rm -f ./*.o


.PHONY: clean
clean:
	rm -f calc dList.lst