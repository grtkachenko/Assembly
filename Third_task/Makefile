all: main.cpp
	yasm -f macho64 algo.asm
	g++ -m64 -o main.o -c main.cpp   
	g++ -Wall -m64 algo.o main.o -o main
	./main
clean: 
	rm -f main
