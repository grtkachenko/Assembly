all: main.cpp
	yasm -f macho32 algo.asm
	g++ -m32 -o main.o -c main.cpp   
	g++ -Wl -m32 algo.o main.o -o main
	rm main.o algo.o
	./main
clean: 
	rm -f main
